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

# create the app server configuration file
sudo echo "server {" >> /etc/nginx/sites-available/ViTeMBP-Dashboard
sudo echo "  listen 3003 default_server;" >> /etc/nginx/sites-available/ViTeMBP-Dashboard
sudo echo "  server_name www.vitembp.com;" >> /etc/nginx/sites-available/ViTeMBP-Dashboard
sudo echo "  passenger_enabled on;" >> /etc/nginx/sites-available/ViTeMBP-Dashboard
sudo echo "  passenger_app_env development;" >> /etc/nginx/sites-available/ViTeMBP-Dashboard
sudo echo "  root /home/ubuntu/ViTeMBP-Dashboard/public;" >> /etc/nginx/sites-available/ViTeMBP-Dashboard
sudo echo "}" >> /etc/nginx/sites-available/ViTeMBP-Dashboard

# enable the server by linking the configuration file to the enabled directory
sudo ln -s /etc/nginx/sites-available/ViTeMBP-Dashboard /etc/nginx/sites-enabled/ViTeMBP-Dashboard

# restart nginex service load new config
sudo service nginx restart

cd ~
cd ViTeMBP-Dashboard
sudo apt-get -y install python-software-properties libffi-dev

#sudo gem install rails
sudo gem install bundler
bundle install
rails db:migrate RAILS_ENV=development

# setup environmental variables for ruby app, user must change these for their setup
sudo echo "export OMNIAUTH_PROVIDER_KEY=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export OMNIAUTH_PROVIDER_SECRET=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export AWS_REGION=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export AWS_ACCESS_KEY_ID=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export AWS_SECRET_ACCESS_KEY=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export S3_UL_BUCKET=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export S3_UL_SUCCESS_BASE=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export S3_UL_ACCESS_KEY=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export S3_UL_ACCESS_SECRET=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export S3_OUTPUT_BUCKET=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export S3_OUTPUT_BUCKET_URL_BASE=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo echo "export SQS_QUEUE_URL=\"\"" >> /etc/profile.d/ViTeMBP.sh
sudo chmod +x /etc/profile.d/ViTeMBP.sh
