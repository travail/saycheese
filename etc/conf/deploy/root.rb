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

  desc 'Finalize update'
  task :finalize_update, roles => [:web, :app] do
  end
end
