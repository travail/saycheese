load 'etc/conf/deploy/root'

set :user,        'mina'
set :deploy_to,   "/home/public/#{application}"

role :web,        '192.168.1.1'
role :app,        '192.168.1.2'
role :saycheesed, '192.168.1.1'
