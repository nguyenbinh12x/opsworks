php_fpm_service_name = "php-fpm"
pool_name = "www"

   template node['php-fpm']['conf_dir'] + "/pools/www.conf" do
     source "pool.conf.erb"
     mode 00644
     owner "root"
     group "root"
     variables(
         :pool_name => 'www',
         :params => params,
         :listen => node['php-fpm']['pool'][pool_name]['listen'],
         :allowed_clients => node['php-fpm']['pool'][pool_name]['allowed_clients'],
         :user => node['php-fpm']['pool'][pool_name]['user'],
         :group => node['php-fpm']['pool'][pool_name]['group'],
         :process_manager => node['php-fpm']['pool'][pool_name]['process_manager'],
         :max_children => node['php-fpm']['pool'][pool_name]['max_children'],
         :start_servers => node['php-fpm']['pool'][pool_name]['start_servers'],
         :min_spare_servers => node['php-fpm']['pool'][pool_name]['min_spare_servers'],
         :max_spare_servers => node['php-fpm']['pool'][pool_name]['max_spare_servers'],
         :max_requests => node['php-fpm']['pool'][pool_name]['max_requests'],
         :request_terminate_timeout => node['php-fpm']['pool'][pool_name]['request_terminate_timeout']
     )
   end

   template node['php-fpm']['conf_file'] do
     source "php-fpm.conf.erb"
     mode 00644
     owner "root"
     group "root"
   end

   service "php-fpm" do
     service_name php_fpm_service_name
     supports :start => true, :stop => true, :restart => true, :reload => true
     action [ :enable, :restart ]
   end