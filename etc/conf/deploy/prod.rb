load 'etc/conf/deploy/root'

set :user,      'mina'
set :deploy_to, "/home/public/#{application}"

role :web,    '192.168.1.1'
role :app,    '192.168.1.2'
role :worker, '192.168.1.1'

namespace :deploy do
  namespace :saycheesed do
    desc 'Start saycheesed'
    task :start do
      run "#{sudo} mv /service/.saycheesed /service/saycheesed"
    end
    desc 'Stop saycheesed'
    task :stop do
      run "#{sudo} mv /service/saycheesed /service/.saycheesed && #{sudo} svc -dx /service/.saycheesed && #{sudo} svc -dx /service/.saycheesed/log"
    end
    desc 'Restart saycheesed'
    task :restart do
      run "#{sudo} svc -t /service/saycheesed && #{sudo} svc -t /service/saycheesed/log"
    end
  end

  desc 'Restart apache'
  task :restart do
    parallel do |session|
      session.when "in?(:web) || in?(:app)", "#{sudo} /etc/rc.d/init.d/httpd restart"
      session.else "echo nothing to do"
    end
  end
end
