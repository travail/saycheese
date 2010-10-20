load 'etc/conf/deploy/root'

set :user,                  'travail'
set :deploy_to,             "/home/travail/git/#{application}"
set :httpd_conf_root,       "#{current_path}/etc/httpd"
set :www_conf_path,         "#{httpd_conf_root}/www.saycheese_local.conf"
set :maintenance_conf_path, "#{httpd_conf_root}/www.saycheese_local_maintenance.conf"
set :saycheesed_name,       'saycheesed_local'
set :fetchtitled_name,      'fetchtitled_local'
set :updatetitled_name,     'updatetitled_local'

role :web,    '192.168.1.1'
role :app,    '192.168.1.2'
role :worker, '192.168.1.1'

namespace :deploy do
end
