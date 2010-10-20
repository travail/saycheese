set :application, 'SayCheese'
set :use_sudo,    false
set :scm, :git
set :repository,  'ssh://git.travail.jp/home/public/GIT_REPOS/saycheese.git'
set :branche,     'master'
set :deploy_via,  :export
set :shared_children, %w(log root/src/include)

namespace :deploy do
  desc 'Setup Catalyst application'
  task :setup, :roles => [:web, :app] do
    dirs = [deploy_to, releases_path, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "mkdir -p #{dirs.join(' ')} && chmod g+w #{dirs.join(' ')}"
    run "chmod -R g+w #{shared_path}/root"
    run "mkdir -p #{shared_path}/cache"
    run "mkdir -p #{shared_path}/cache/tt"
    run "chmod -R 777 #{shared_path}/cache"
  end

  # finalize update
  desc 'Finalize update'
  task :finalize_update, roles => [:web, :app] do
    run <<-CMD
      ln -s #{www_conf_path} #{release_path}/etc/httpd/web.conf
    CMD
  end

  # worker
  namespace :saycheesed do
    desc 'Start saycheesed'
    task :start do
      daemon_start "#{saycheesed_name}"
    end
    desc 'Stop saycheesed'
    task :stop do
      daemon_stop "#{saycheesed_name}"
    end
    desc 'Restart saycheesed'
    task :restart do
      daemon_restart "#{saycheesed_name}"
    end
  end

  namespace :fetchtitled do
    desc 'Start fetchtitled'
    task :start do
      daemon_start "#{fetchtitled_name}"
    end
    desc 'Stop fetchtitled'
    task :stop do
      daemon_stop "#{fetchtitled_name}"
    end
    desc 'Restart fetchtitled'
    task :restart do
      daemon_restart "#{fetchtitled_name}"
    end
  end

  namespace :updatetitled do
    desc 'Start updatetitled'
    task :start do
      daemon_start "#{updatetitled_name}"
    end
    desc 'Stop updatetitled'
    task :stop do
      daemon_stop "#{updatetitled_name}"
    end
    desc 'Restart updatetitled'
    task :restart do
      daemon_restart "#{updatetitled_name}"
    end
  end

  # httpd
  desc 'Restart apache'
  task :restart do
    parallel do |session|
      session.when "in?(:web) || in?(:app)", "#{sudo} /etc/rc.d/init.d/httpd restart"
      session.else "echo Nothing to do"
    end
  end

  namespace :web do
    desc ''
    task :enable, :roles => :web do
      run <<-CMD
        rm -f #{httpd_conf_root}/web.conf &&
        ln -s #{www_conf_path} #{current_path}/etc/httpd/web.conf &&
        #{sudo} /etc/rc.d/init.d/httpd reload
      CMD
    end
    desc ''
    task :disable, :roles => :web do
      run <<-CMD
        rm -f #{httpd_conf_root}/web.conf &&
        ln -s #{maintenance_conf_path} #{current_path}/etc/httpd/web.conf &&
        #{sudo} /etc/rc.d/init.d/httpd reload
      CMD
    end
  end

  # utilities
  def daemon_start(name)
      run "#{sudo} mv /service/.#{name} /service/#{name}"
  end
  def daemon_stop(name)
      run "#{sudo} mv /service/#{name} /service/.#{name} && #{sudo} svc -dx /service/.#{name} && #{sudo} svc -dx /service/.#{name}/log"
  end
  def daemon_restart(name)
    run "#{sudo} svc -t /service/#{name} && #{sudo} svc -t /service/#{name}/log"
  end
end
