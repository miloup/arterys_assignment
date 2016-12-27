## About this cookbook

This cookbook installs/configures 'node-static' and nginx to display the chef-solo run output log on your browser. Node-static has been used to server the Chef-run output log, save it to "/tmp/output.log" and Nginx as a reverse proxy with an SSL self-signed certifate along with an HTTP basic authentication. At the end, it will send an HTTP POST request to an arbitrary URL

## Encountered issues

For some reason, I was unable to serve the static file in Node.js in daemon mode after the chef run. Even though node.js seems to be running in the background after the Chef-run, the webpage remains unreachable. It requires to manually start node.js using 'forever' once the Chef-run is complete.
Tried methods:
  - nohup (bash)
  - pm2 (npm)
  - forever (npm)

## Supported Platforms

This cookbook can ONLY work on an Ubuntu distribution due to the nginx config file path that changes from a Linux distribution to another. The cookbook has been tested on Ubuntu 14.04

## Prerequisites

In order for this cookbook to work, you will need the following:
  - Ubuntu OS (It worked on 14.04, don't know about the other versions... you can still give it a shot :) )
  - ChefDK installed.
  - The user that will run the command 'chef-solo' has to have root privleges without password authentication.

## What does this cookbook do?

When executing **chef-solo**, the cookbook will do the following:

1. Install _Nginx_ and _apache2-util_. _Apache2-util_ contains _htpasswd_ that allow to create the credentials to login to the page when the authentication window will pop up.
2. Overwrite the default Nginx config file under _/etc/nginx/sites-available/default_ by the template _nginx.conf.erb_
3. Execute a bash script that will generate the SSL self-signed certificate.
4. Create _.htpasswd_ file that will contain the credentials from the attribute file _./attributes/default.rb_. Feel free to edit the credentials on this template file.
5. Restart nginx service so that the changes will take effect
6. Install Node.js with the required depencies for this project
7. Install _node-static_ and _forever_ using _npm_, with _forever_ being an npm module to start _node-static_ as daemon.  
8. Create _server.js_ under /tmp/ folder. This file contains the JavaScript script to tell node-static which file to serve.
9. Post a basic HTTP message to the URL defined in _template/default.rb_. A ruby\_block will get the URL response code. If the URL response code is 2xx or 3xx, it will notifiy the http\_request chef resource to proceed to an an HTTP POST on that URL. Otherwise it will skip and display a warning log message during the chef-run
 
## How to use this cookbook

1. Change to the directory where you want to clone this repo (ex: cd /home/user/cookbooks).
2. Clone this repo using: **git clone https://github.com/miloup/arterys_assignment.git**
3. cd to the cloned repo: **cd arterys_assignment**
3. Before running 'chef-solo', you will need to first execute the file first\_script.sh. This file will put together the necessary information and create the files needed to run 'chef-solo'. Also, make sure the file 'first\_script.sh' has execute permission (chmod +x ./first\_script.sh)
4. Run chef-solo as follow: **chef-solo -c ./nodes/solo.rb -j ./nodes/file.json | tee /tmp/output.log**. The "tee /tmp/output.log" will save the chef-run output log into a file while they're being displayed on your screen.
5. As explained in the section **Encountered issues**, you won't be able to see the log file on your browser after the chef-run is finished. The chef-resource to start node.js has been commented out in cookbook, and you will need to start node.js manually using 'forever'. To manually start node.js, run the following command on your shell:
   * **sudo su -**
   * **forever start /tmp/server.js**
6. Open your browser and put in the address bar **https://** followed by the ip of your current server: **https://your_ip**
7. When the authentication window pops up, put in as username "rafik" and password "123456" (in case you didn't modify the credentials)

## Questions/Answers
### Q1: Explain various options available to email the chef-solo log file when the installation is complete.
Log files in Linux systems are usually sent using MTAs (Mail Transfert Agent). The log file file can be sent as an email body using software such as _postfix_ or as an attachment using software like _mutt_
You can also create a chef recipe with a ruby\_block that uses Net::SMTP to accomplish the task

### Q2: Explain various options available to monitor the system logs on this server remotely.
There many options to remotly monitor system logs. Some of the famous Linux open-source options are:
- rsyslog: The server that contains the log sends the file to the remote one.
- ssh: Ssh from server-A to server-B that contains the log file and view/tail it
- http: View logs remotly from your browser using http servers such as Nginx or Apache
