set :stages, %w(staging prod testing admin)
set :stage_dir, "etc/conf/deploy"
require "capistrano/ext/multistage"
