###############################
##### Main and only recipe #####
################################

package ['nginx','curl','apache2-utils'] do
   action :install
end

template '/etc/nginx/sites-available/default' do
   source 'nginx.conf.erb'
   action :create
end

execute 'create_ssl_folders' do
   command "mkdir -p /etc/ssl/private/ /etc/ssl/certs/ /etc/nginx/snippets/"
end

execute 'Create_ssl_certificate' do
   command 'openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=GA/L=Atlanta/O=arterys.com/OU=IT/emailAddress=raf_ben@hotmail.com"'
end

execute 'Create_pem_file' do
   command "openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048"
end

template '/etc/nginx/snippets/self-signed.conf' do
      source 'self-signed.conf.erb'
end

template '/etc/nginx/snippets/ssl-params.conf' do
      source 'ssl-params.conf.erb'
end

execute 'http_credentials' do
   command "htpasswd -b -c /etc/nginx/.htpasswd #{node['http']['username']} #{node['http']['password']}"
end

service 'nginx' do
   action :restart
end

execute 'prepare_nodejs' do
   command 'curl -sL https://deb.nodesource.com/setup_6.x | bash -'
end

apt_package ['nodejs','build-essential'] do
   action :install
end

template "#{node['nodejs']['path']}/server.js" do
   source 'server2.js.erb'
end

execute 'install node-static' do
   user 'root'
   cwd "#{node['nodejs']['path']}"
   command 'npm install -g node-static'
end

execute 'install forever' do
   user 'root'
   cwd "#{node['nodejs']['path']}"
   command 'npm install -g forever'
end

### The below 'execute' resource does not work properly 

#execute 'Start node-static in daemon' do
#   user 'root'
#   command "forever start /tmp/server.js"
#end

#### HTTP Post #### 
ruby_block 'HTTP POST' do
   block do
     require 'net/http'
     http_res = Net::HTTP.get_response(URI.parse("#{node['http']['post']['url']}"))
     if(http_res.code =~ /2|3\d{2}/ ) then
        notifies :post, 'http_request[http_post]', :immediately
     else
        Chef::Log.warn('The URL is not configured for HTTP post. Skipping...')
     end
   end
end

http_request 'http_post' do
   message node['http']['post']['message']
   url node['http']['post']['url']
   action :nothing
end
