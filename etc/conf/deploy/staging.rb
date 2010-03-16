load 'etc/conf/deploy/root'

set :user,        'travail'
set :deploy_to,   "/home/travail/git/#{application}"

role :web,        '192.168.1.1'
role :app,        '192.168.1.2'
role :saycheesed, '192.168.1.1'

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
