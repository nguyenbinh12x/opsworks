package "php-fpm"

include_recipe "php-fpm::service"

service "php-fpm" do
  action [ :enable, :start ]
end
