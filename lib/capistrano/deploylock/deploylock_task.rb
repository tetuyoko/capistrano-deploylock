namespace :deploy do
set :deploy_lock_file, 'deploy_lock.yml'
set :deploy_lock_log_file, 'deploy_lock.log'
set :deploy_lock_file_remote_path, "#{shared_path}/system/#{deploy_lock_file}"
set :deploy_lock_file_remote_log_path, "#{shared_path}/system/#{deploy_lock_log_file}"
set :deploy_lock_file_local_path, "./public/system/#{deploy_lock_file}"

before "deploy:lock:start", "deploy:lock:check"
before "deploy", "deploy:lock:start"

#TODO: productionでも使えちゃうので移動する
  namespace :lock do
    desc 'デプロイロックする'
    task :start, roles: :web do
      on_rollback { rm deploy_lock_file_remote_path }
  
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
  
      erb = ERB.new(File.read("#{deploy_lock_file_local_path}.erb")).result(binding)
        put erb, "#{deploy_lock_file_remote_path}", mode: 0644
        lock_start_log
      end

    task :end, roles: :web do
      lock_force_end(true)
    end

    desc 'デプロイロックを確認する'
    task :check, roles: :web do
      unless remote_file_exists?(deploy_lock_file_remote_path)
        puts '[SKIP] ロックファイルがありません.'
        next
      end

      FileUtils.rm deploy_lock_file_local_path, force: true

      get deploy_lock_file_remote_path, deploy_lock_file_local_path
      lock = YAML.load_file deploy_lock_file_local_path

      if Time.now > lock["expired_at"]
         puts '[SKIP] ロックファイルの設定期限が過ぎています.'
         lock_force_end(false)
         next
       end

      current_user = git_config_user_name.chomp
      if lock["user"] == current_user
        puts '[SKIP] あなたのロックファイルです.'
        next
      end

      puts "\n**** [LOCKED] #{rails_env}はロックされ、有効期限内です. **** "
      puts "\n  locked_user  : #{lock["user"]}"
      puts "  expired_at   : #{lock["expired_at"]}\n\n"

      puts "ロックは下記のコマンドで取り消しできます。"
      puts "bundle exedc cap $STAGENAME deploy:lock:end"

      FileUtils.rm './public/system/deploy_lock.yml', force: true
      run "hostname; exit 1"
    end
  end
end
