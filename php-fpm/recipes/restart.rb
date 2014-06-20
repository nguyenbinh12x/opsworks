service "php-fpm" do
  service_name "php-fpm"
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [ :restart ]
end