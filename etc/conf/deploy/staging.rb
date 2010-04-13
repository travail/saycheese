load 'etc/conf/deploy/root'

set :user,        'travail'
set :deploy_to,   "/home/travail/git/#{application}"

role :web,    '192.168.1.1'
role :app,    '192.168.1.2'
role :worker, '192.168.1.1'

namespace :deploy do
  namespace :saycheesed do
    desc 'Start saycheesed'
    task :start do
      run "#{sudo} mv /service/.saycheesed_local /service/saycheesed_local"
    end
    desc 'Stop saycheesed'
    task :stop do
      run "#{sudo} mv /service/saycheesed_local /service/.saycheesed_local && #{sudo} svc -dx /service/.saycheesed_local && #{sudo} svc -dx /service/.saycheesed_local/log"
    end
    desc 'Stop saycheesed'
    task :restart do
      run "#{sudo} svc -t /service/saycheesed_local && #{sudo} svc -t /service/saycheesed_local/log"
    end
  end

  desc 'Restart apache'
  task :restart do
    parallel do |session|
      session.when "in?(:web) || in?(:app)", "echo Nothing to do"
      session.else "echo Nothing to do"
    end
  end
end
