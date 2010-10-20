load 'etc/conf/deploy/root'

set :user,                  'mina'
set :deploy_to,             "/home/public/#{application}"
set :httpd_conf_root,       "#{current_path}/etc/httpd"
set :www_conf_path,         "#{httpd_conf_root}/www.saycheese.conf"
set :maintenance_conf_path, "#{httpd_conf_root}/www.saycheese_maintenance.conf"
set :saycheesed_name,       'saycheesed'
set :fetchtitled_name,      'fetchtitled'
set :updatetitled_name,     'updatetitled'

role :web,    '192.168.1.1'
role :app,    '192.168.1.2'
role :worker, '192.168.1.1'

namespace :deploy do
end
