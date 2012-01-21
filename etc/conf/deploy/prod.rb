load 'etc/conf/deploy/root'

set :user,                        "mina"
set :deploy_to,                   "/home/public/#{application}"
set :httpd_conf_root,             "/etc/httpd/conf.d/saycheese.d"
set :www_conf_file,               "www.saycheese.conf"
set :www_maintenance_conf_file,   "www.saycheese_maintenance.conf"
set :thumb_conf_file,             "thumb.saycheese.conf"
set :thumb_maintenance_conf_file, "thumb.saycheese_maintenance.conf"
set :saycheesed_name,             "saycheesed"
set :fetchtitled_name,            "fetchtitled"
set :updatetitled_name,           "updatetitled"

role :web,    "192.168.1.1"
role :app,    "192.168.1.2"
role :worker, "192.168.1.1"

namespace :deploy do
end
