# Include nginx
include_recipe "nginx::stop"

service "php-fpm" do
  action :stop
end
