## About this cookbook

This cookbook installs/configures 'node-static' and nginx to display the chef-solo run output log on your browser. Node-static has been used to server the static file "some_chef_log" and Nginx as a reverse proxy with an SSL self-signed certifate along with an HTTP basic authentication.

## Encountered issues

For some reason, I was unable to serve the static file in Node.js in daemon mode after the chef run. 
Methods used:
  - nohup (bash)
  - forever (npm)
  - pm2 (npm)

## Supported Platforms

This cookbook can ONLY work on an Ubuntu distribution due to the nginx config file path that changes from a Linux distribution to another. My test was performed on Ubuntu 14.04

## Prerequisites

In order for this cookbook to work, you will need the following:
  - Ubuntu OS (It worked on 14.04, don't know about the other versions... you can still give it a shot :) )
  - ChefDK installed.
  - The user that will run the command 'chef-solo' has to have root privleges (i.e. can use 'sudo').

## What does this cookbook do?

When executing **chef-solo**, the cookbook will do the following:

1. Install _Nginx_ and _apache2-util_. Apache2-util will allow to create the credentials to login to the page when the authentication window will pop up.
2. Overwrite the Nginx config file under _/etc/nginx/sites-available/default_ by the template _nginx.conf.erb_
3. Execute a bash script that will generate the SSL self-signed certificate
4. Create _.htpasswd_ file that will contain the credentials from the attribute file _./attributes/default.rb_. You can have your own credentials by editing this file
5. Restart nginx service so that the changes will take effect
6. Install Node.js with the required depencies for this project
7. Install _node-static_ and _forever_ using _npm_
8. Create _server.js_ under /tmp/ folder. This file contains the JavaScript script to tell node-static what to display

 
## How to use this cookbook

1. Change to the direcroty where you want to clone this repo (ex: cd /home/user/cookbooks).
2. Clone this repo using: **git clone https://github.com/miloup/arterys_assignment.git**
3. Before running 'chef-solo', you will need to execute the file first_script.sh. This file will put together the necessary information and create the files needed to run 'chef-solo'. Also, make sure the file 'first_script.sh' has execute permission (chmod +x ./first_script.sh)
4. Run chef-solo as follow: **chef-solo -c ./nodes/solo.rb -j ./nodes/file.json | tee /tmp/output.log**
5. As explained in the section **Encountered issues**, I wasn't able to start node.js as daemon correctly. After finishing **step 4** you will need to run the following commands:
  * _sudo su -_
  * _forever start /tmp/server.js_
6. Open you browser and put in the URL bar 'https://' followed by the ip of your current server: **https://your_ip**
7. When the authentication window pops up, put in as username "rafik" and password "123456"

## Questions/Answers
### Q1: Explain various options available to email the chef-solo log file when the installation is complete.
Log files in Linux systems are usually sent using MTAs (Mail Transfert Agent). The log file file can be sent as an email body using software such as _postfix_ or as an attachment using software like _mutt_

### Q2: Explain various options available to monitor the system logs on this server remotely.
There many options to remotly monitor system logs. Some of the famous Linux open-source options to achieve the task are:
- rsyslog: The server that contains the log sends the file to the remote one.
- ssh: Ssh from server-A to server-B that contains the log file and view it
- http: View logs remotly from your browser using http servers such as Nginx or Apache


