# About this cookbook

This cookbook installs/configures 'node-static' and nginx to display the chef-solo run output log on your browser. Node-static has been used to server the static file "some_chef_log" and Nginx as a reverse proxy with an SSL self-signed certifate along with an HTTP basic authentication.

## Supported Platforms

This cookbook can ONLY work on an Ubuntu distribution due to the nginx config file path that changes from a Linux distribution to another. My test was performed on Ubuntu 14.04

## Prerequisites

In order for this cookbook to work, you will need the following:
  - Ubuntu OS (It worked on 14.04, don't know about the other versions... you can still give it a shot :) )
  - ChefDK installed.
  - The user that will run the command 'chef-solo' has to have root privleges (i.e. can use 'sudo').

## How to use this cookbook

1- Change to the direcroty where you want to clone this repo (ex: cd /home/user/cookbooks)
2- Clone this repo using: git clone https://github.com/miloup/arterys_assignment.git

Before running 'chef-solo', you will need to execute the file first_scrspt.sh. This file will put together the necessary information and create the files needed to run 'chef-solo'. Also, make sure the file 'first_script.sh' has execute permission (chmod +x /path/to/first_script.sh)



