require "capistrano/deploylock/version"
require 'capistrano'

module Capistrano::Deploylock

  def self.load_into(configuration)
    configuration.load do
      _cset :deploy_lock_basename, "deploy_lock"
      _cset(:deploy_lock_dirname) { "#{shared_path}/system" }
      _cset(:deploy_lock_template_path) { File.join(File.dirname(__FILE__), "templates", "deploy_lock.yml") }
      _cset(:deploy_lock_remote_path) { "#{deploy_lock_dirname}/#{deploy_lock_basename}.yml" }
      _cset(:deploy_lock_remote_log_path) {"#{deploy_lock_dirname}/#{deploy_lock_basename}.log" }
      _cset(:deploy_lock_file_local_path) {"./public/system/#{deploy_lock_basename}.yml" }

      def remote_file_exists?(full_path)
        'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
      end

      def lock_force_end(with_log=false)
        if remote_file_exists?(deploy_lock_remote_path)
          puts '[SKIP] ロックファイルを削除します'
          lock_end_log if with_log
          run "rm -f #{deploy_lock_remote_path}"
        end
      end

      def lock_start_log
        run "echo [started], #{Time.now}, #{git_config_user_name} >> #{deploy_lock_remote_log_path}"
      end

      def lock_end_log
        run "echo [ended], #{Time.now}, #{git_config_user_name} >> #{deploy_lock_remote_log_path}"
      end

      def git_config_user_name
        `git config --get user.name`
      end

      def remove_local_file
        FileUtils.rm deploy_lock_file_local_path, force: true
      end

      namespace :deploy do
        namespace :lock do
          desc 'デプロイロックを確認する'
          task :start, roles: :web do
            on_rollback { run "rm -f #{deploy_lock_remote_path}" }
            require 'erb'
            puts "\n**** [DEPLOY LOCK] ****"
            puts "24時間後まであなたの名前を元に他人のデプロイをロックします。"
            puts "この操作は下記のコマンドで取り消しできます。"
            puts "bundle exedc cap $STAGENAME deploy:lock:end"

            #      対話用
            #      print "\n今日から何日間ロックしますか? [1-10/n]: "
            #      STDOUT.flush
            #      ans= STDIN.gets.chomp
            #      if ["", 'n'].include? ans
            #        puts "[SKIPPED] デプロイロックをスキップしました。"
            #        exit
            #      end
            #  
            #      day = ans.to_i
            #      unless (1..10).include?(day)
            #        puts "[FAILED] days must set [1-10/n]"
            #        exit
            #      end

            day = 1
            expired_at = Time.now + (day * (60 * 60 * 24))

            user = `users`.chomp
            puts "\n**** [LOCKED] #{rails_env}はロックされ、有効期限内が設定されました. **** "
            puts "\n  locked_user  : #{user}"
            puts "  expired_at   : #{expired_at}\n\n"

            erb = ERB.new(File.read("#{deploy_lock_template_path}.erb")).result(binding)
            put erb, "#{deploy_lock_remote_path}", mode: 0644
            lock_start_log
          end

          desc 'デプロイロックを解除する'
          task :end, roles: :web do
            lock_force_end(true)
          end

          desc 'デプロイロックを設定する'
          task :check, roles: :web do
            unless remote_file_exists?(deploy_lock_remote_path)
              puts '[SKIP] ロックファイルがありません.'
              next
            end

            FileUtils.rm deploy_lock_file_local_path, force: true
            FileUtils.mkdir_p './public/system'

            get deploy_lock_remote_path, deploy_lock_file_local_path
            lock = YAML.load_file deploy_lock_file_local_path

            if Time.now > lock["expired_at"]
              puts '[SKIP] ロックファイルの設定期限が過ぎています.'
              remove_local_file
              lock_force_end(false)
              next
            end

            current_user = git_config_user_name.chomp
            if lock["user"] == current_user
              puts '[SKIP] あなたのロックファイルです.'
              remove_local_file
              next
            end

            puts "\n**** [LOCKED] #{rails_env}はロックされ、有効期限内です. **** "
            puts "\n  locked_user  : #{lock["user"]}"
            puts "  expired_at   : #{lock["expired_at"]}\n\n"

            puts "ロックは下記のコマンドで取り消しできます。"
            puts "bundle exedc cap $STAGENAME deploy:lock:end"

            remove_local_file
            run "hostname; exit 1"
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Deploylock.load_into(Capistrano::Configuration.instance)
end
