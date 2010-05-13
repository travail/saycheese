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
  namespace :fetchtitled do
    desc 'Start fetchtitled'
    task :start do
      run "#{sudo} mv /service/.fetchtitled /service/fetchtitled"
    end
    desc 'Stop fetchtitled'
    task :stop do
      run "#{sudo} mv /service/fetchtitled /service/.fetchtitled && #{sudo} svc -dx /service/.fetchtitled && #{sudo} svc -dx /service/.fetchtitled/log"
    end
    desc 'Restart fetchtitled'
    task :restart do
      run "#{sudo} svc -t /service/fetchtitled && #{sudo} svc -t /service/fetchtitled/log"
    end
  end
  namespace :updatetitled do
    desc 'Start updatetitled'
    task :start do
      run "#{sudo} mv /service/.updatetitled /service/updatetitled"
    end
    desc 'Stop updatetitled'
    task :stop do
      run "#{sudo} mv /service/updatetitled /service/.updatetitled && #{sudo} svc -dx /service/.updatetitled && #{sudo} svc -dx /service/.updatetitled/log"
    end
    desc 'Restart fetchtitled'
    task :restart do
      run "#{sudo} svc -t /service/updatetitled && #{sudo} svc -t /service/updatetitled/log"
    end
  end
end
