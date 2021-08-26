#!/bin/bash
#install ruby manager, mysql-client and other dependencies
sudo apt update
sudo apt-get install -y build-essential git libsqlite3-dev libssl-dev libzlcore-dev mysql-client libmysqlclient-dev git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs npm


#install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt update
sudo apt install -y yarn

#Install rbenv ruby package manager
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
source ~/.bash_profile

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

#install ruby 3.0.1
#todo make it a param in ORM

rbenv install 3.0.1
rbenv global 3.0.1
ruby -v

#install ruby version 3.0.1

#Use version 3.0.1 and make it default
rbenv local 3.0.1
source ~/.bash_profile
#make sure that the ruby execs are used

#Install rails and bundler gems
gem install rails
gem install bundler

#create an app
sudo mkdir /opt/apps
sudo chown ubuntu:ubuntu /opt/apps
cd /opt/apps
rails new myapp -d mysql

#Open port 8080 for HTTP
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT

#move database config to the application
cd myapp
mv /home/ubuntu/database.yml /opt/apps/myapp/config/database.yml
rake db:create
rake db:migrate

#start rails server bind all interfaces
rails s -p 8080 -b 0.0.0.0 >> ./log/startup.log &
