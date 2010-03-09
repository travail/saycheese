load 'etc/conf/deploy/root'
set :application, 'SayCheese'
set :user,        'travail'
set :deploy_via,  :export
set :deploy_to,   "/home/travail/git/#{application}"

namespace :deploy do
  desc 'Restart apache'
  task :restart do
    parallel do |session|
      session.when "in?(:web) || in?(:app)", "echo web or app"
      session.when "in?(:saycheesed)", "echo This is saycheesed"
      session.else "echo nothing to do"
    end
  end
end
