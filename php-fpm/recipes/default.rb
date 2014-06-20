# Include nginx
include_recipe "nginx"

php_fpm_service_name = "php-fpm"
# php-pecl-apc tends to throw segfaults, use "pecl install apc" instead
# pre-install following packages to support proper php-fpm
packages = [
  'php54',
  'php54-fpm',
  'php54-devel',
  'php54-common',
  'pcre-devel',
  'mysql',
  'php54-xml',
  'php54-xmlrpc',
  'php54-gd',
  'php54-cli',
  'php54-mysql',
  'php54-mcrypt',
  'php54-soap',
  'php54-pecl-memcached',
  'php54-mbstring'
]

# install all the packages
packages.each do |up_package|
  package up_package do
    action :upgrade
  end
end

# prepare default optimization params for each of CMS site
template "/etc/nginx/default-params" do
  source "etc-nginx-default-params.erb"
  owner  "root"
  group  "root"
  mode   0644
end

# prepare PHP for nginx configurations to listen to WWW pool
template "/etc/nginx/enable-php" do
  source "etc-nginx-enable-php.erb"
  owner  "root"
  group  "root"
  mode   0644
  variables(
    :socket => node['php-fpm']['pool']['www']['listen']
  )
end

# try to install apc with pecl
bash "install_pecl_apc" do
  user "root"
  code <<-EOH
    printf "\n" | pecl install apc
    exit 0
  EOH
  returns [0,'1',1]
end

# configure custom apc.ini
etc_dir  = "/etc/php.d"
conf_apc = "apc.ini"

template "#{etc_dir}/#{conf_apc}" do
  source 'apc.ini.erb'
  owner  'root'
  group  'root'
  mode   0644
  
  variables(
    :enabled        => (node[:server][:apc][:enabled]  rescue '1'),
    :shm_size       => (node[:server][:apc][:shm_size] rescue '128M'),
    :gc_ttl         => (node[:server][:apc][:gc_ttl]   rescue '900')
  )  
end

# some network optimizations
bash "tcp_keepalive_time" do
  user "root"
  code <<-EOH
    echo 300 | sudo tee /proc/sys/net/ipv4/tcp_keepalive_time
  EOH
end

# stop sendmail service
bash "stop_and_disable_sendmail" do
  user "root"
  code <<-EOH
    chkconfig sendmail off
    service sendmail stop
  EOH
end

include_recipe "php-fpm::phpsettings"

template node['php-fpm']['conf_file'] do
  source "php-fpm.conf.erb"
  mode 00644
  owner "root"
  group "root"
end

node['php-fpm']['pools'].each do |pool|
  fpm_pool pool do
    php_fpm_service_name php_fpm_service_name
  end
end

service "php-fpm" do
  service_name php_fpm_service_name
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end
