set :stages, %w(staging prod testing admin)
set :stage_dir, "etc/conf/deploy"
require "capistrano_colors"
require "capistrano/ext/multistage"
