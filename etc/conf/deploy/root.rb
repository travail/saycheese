require 'capistrano_colors'

set :application, 'SayCheese'
set :user,        'mina'
set :scm, :git
set :repository,  'ssh://git.travail.jp/home/public/GIT_REPOS/saycheese.git'
set :branche,     'master'
set :deploy_via,  :export
set :deploy_to,   "/home/public/#{application}"

role :web,        '192.168.1.1'
role :app,        '192.168.1.2'
role :saycheesed, '192.168.1.1'

set :shared_children, %w(log root/src/include)

namespace :deploy do
  desc 'Setup Catalyst application'
  task :setup, :roles => [:web, :app] do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "mkdir -p #{dirs.join(' ')} && chmod g+w #{dirs.join(' ')}"
    run "chmod -R g+w #{shared_path}/root"
  end

  desc 'Finalize update'
  task :finalize_update, roles => [:web, :app] do
  end

  desc 'Restart apache'
  task :restart do
    parallel do |session|
      session.when "in?(:web) || in?(:app)", "#{sudo} /etc/rc.d/init.d/httpd restart"
      session.when "in?(:saycheesed)", "echo This is saycheesed"
      session.else "echo nothing to do"
    end
  end
end
