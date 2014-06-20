# set default timezone
bash "set_default_php_timezone" do
  user "root"
  code <<-EOH
    echo "date.timezone = America/New_York" | sudo tee /etc/php.d/date.ini
  EOH
end

# set default timezone
bash "set_php_session_path" do
  user "root"
  code <<-EOH
    echo "session.save_path = /tmp" | sudo tee /etc/php.d/sess.ini
  EOH
end

service "php-fpm" do
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [ :reload ]
end
