require "capistrano/deploylock/version"
require 'capistrano'

module Capistrano::Deploylock
  def self.load_into(configuration)
    configuration.load do
      _cset(:maintenance_dirname) { "#{shared_path}/system" }
      _cset :maintenance_basename, "maintenance"
      _cset(:maintenance_template_path) { File.join(File.dirname(__FILE__), "templates", "maintenance.html.erb") }

      namespace :deploy do
        namespace :web do
          desc 'hoge'
          task :disablehoge, :roles => :web, :except => { :no_release => true } do
            require 'erb'
            on_rollback { run "rm -f #{maintenance_dirname}/#{maintenance_basename}.html" }

            template = File.read(maintenance_template_path)
            result = ERB.new(template).result(binding)

            put result, "#{maintenance_dirname}/#{maintenance_basename}.html", :mode => 0644
          end

          desk 'hiu'
          task :enablehoge, :roles => :web, :except => { :no_release => true } do
            run "rm -f #{maintenance_dirname}/#{maintenance_basename}.html"
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Deploylock.load_into(Capistrano::Configuration.instance)
end
