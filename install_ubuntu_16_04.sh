sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3

sudo apt-get -y install ruby ruby-dev

# install Passenger pgp certificates
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Nginx
sudo apt-get install -y nginx-extras passenger

# uncomment passenger include with sed
sudo sed -i 's/# include \/etc\/nginx\/passenger.conf;/include \/etc\/nginx\/passenger.conf;/' /etc/nginx/nginx.conf

# create a http to https redirect
sudo sed -i 's/server_name _;/server_name _;\n\trewrite ^\/$ https:\/\/www.vitembp.com\/ redirect;/' /etc/nginx/sites-enabled/default

#start nginex service
sudo service nginx restart

cd ~
cd ViTeMBP-Dashboard
sudo apt-get -y install python-software-properties libffi-dev

#sudo gem install rails
sudo gem install bundler
bundle install
rails db:migrate RAILS_ENV=development