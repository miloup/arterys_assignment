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

execute 'ssl_encryption' do
   command "mkdir -p /etc/ssl/private/ /etc/ssl/certs/ /etc/nginx/snippets/ && rm -rf /etc/ssl/private/* /etc/ssl/certs/* /etc/nginx/snippets/*"
   command 'openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=US/ST=GA/L=Atlanta/O=arterys.com/OU=IT/emailAddress=raf_ben@hotmail.com"'
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
#   command 'apt-get update'
end

package ['nodejs','build-essential'] do
   action :install
end

template "#{node['nodejs']['path']}/server.js" do
   source 'server2.js.erb'
end

#execute 'convert_log_to_html' do
#   command "sed -e 's/^/<p>/' -e 's/$/<\/p>/' -i #{node['nodejs']['path']}/index.html"
#end


execute 'install pm2 and node-static' do
   command 'npm install -g pm2 node-static'
end

execute 'Start node-static in daemon' do
   cwd "#{node['nodejs']['path']}"
   command "nohup node ./server.js &"
#   command "pm2 start #{node['nodejs']['path']}/server.js"
end
