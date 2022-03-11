
## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
#!/bin/bash 

#install ruby manager, mysql-client and other dependencies
sudo apt update
sudo apt-get install -y build-essential git libsqlite3-dev libssl-dev libzlcore-dev mysql-client libmysqlclient-dev git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs npm



#install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update
sudo apt install -y yarn

sudo apt-get install -y ruby-full
sudo gem install rails
ruby -v

#Install rails and bundler gems
sudo gem install rails
sudo gem install bundler

#create an app
sudo mkdir /opt/apps
sudo chown ubuntu:ubuntu /opt/apps
cd /opt/apps
rails new myapp -d mysql

#Open port 8080 for HTTP
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT

#move database config to the application
cd /opt/apps/myapp/
mv /home/ubuntu/database.yml /opt/apps/myapp/config/database.yml
rake db:create 
rake db:migrate  

# move database config to the application
sudo chmod +x /home/ubuntu/start_rails.sh
sudo mv /home/ubuntu/start_rails.sh /opt/apps/myapp/


#add start_rails as a service
sudo mv /home/ubuntu/shellscript.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable shellscript.service 
sudo systemctl start shellscript.service




