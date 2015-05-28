#!/bin/bash
#
# Get. Set. Rails.
#
# Licence: MIT
# Maintained by: DevOps at Skcript
# 
# Please reach out to us if you have any queries. bello@skcript.com
# Here's the plan: 
# 1. Set the global variables (Like Ruby version and location and working directory)
# 2. Make sure you give the user a feedback about the termination on Ctrl+C
# 3. Determine the kernel (Darwin or Linux) - Right now, trying only on Linux
# 4. Ask the user how he would like to install Ruby (RVM or Source)
# 5. Install the dependencies for Ubuntu 
# 6. Install Ruby Gems after installing Ruby
# 7. Give the user a hug. And thank them for using it
#

# 1. Global variable setup
shopt -s nocaseglob
set -e

ruby_version="2.1.5"
ruby_version_string="2.1.5"
ruby_source_url="http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz"
ruby_source_tar_name="ruby-2.1.5.tar.gz"
ruby_source_dir_name="ruby-2.1.5"
which_user=$(whoami)
getsetrails_path=$(cd && pwd)/getsetrails
log_file="$getsetrails_path/rails_install.log"
system_os=$(uname | env LANG=C LC_ALL=C LC_CTYPE=C tr '[:upper:]' '[:lower:]')

ctrl_c()
{
  echo -en "\n\n========== Exiting ==========\n\n"
  exit 1
}

# 2. Handle Ctrl+C feedback
trap ctrl_c SIGINT

clear

echo "#####################################"
echo "########## Get. Set. Rails ##########"
echo "#####################################"


# 3. Check Distro Version
if [[ $system_os = *linux* ]] ; then
  distro_name=$(cat /etc/issue) # Get Distro Version from its corresponding file
  if [[ $distro_name =~ ubuntu ]] ; then
    distro="ubuntu" # Store Distro Value
  fi
else # Handle exceptions.
  echo -e "\nGet. Set. Rails. currently supports Ubuntu 14.04\n"
  exit 1
fi

# Help users to track the log file
echo -e "\n\n"
echo "Please run tail -f $log_file in a new terminal to check what installation is being done."

# Give users some more information before the installation begins
echo -e "\n"
echo "What are we trying to install here:"
echo " * Ruby versio $ruby_version_string"
echo " * Essential dependencies like SQLite, MySQL"
echo " * Latest version of Bundler"
echo " * Rubygems with Passenger"
echo " * Git Core "

echo -e "\n"
echo "If there are any bugs, please report it to https://github.com/skcript/get-set-rails/issues/new/"

# Now get to real business - Check user permissions
sudo -v >/dev/null 2>&1 || { echo $which_user has no sudo privileges ; exit 1; }

# Ask em. How Ruby should be installed
echo -e "\n"
echo "How do you want to build your Ruby?"
echo "=> 1. From source"
echo "=> 2. Install using RVM"
echo -n "Select your installation type [1 or 2]? "
read installType

# Obey user input
if [ $installType -eq 1 ] ; then
  echo -e "\n\n*** We are now set to install Ruby from Source, System wide. ***\n"
elif [ $installType -eq 2 ] ; then
  echo -e "\n\n*** We are now set to install Ruby from RVM, for $which_user *** \n"
else
  echo -e "\n\n*** Well, you should totally choose a way to install Ruby on your system. ***"
  exit 1
fi

# Let us now prepare the system for downloading and installing Ruby
echo -e "\n=> Now creating: Installation Directory..."
cd && mkdir -p getsetrails/src && cd getsetrails && touch rails_install.log
echo "==> All set..."

# Download and run the necessary dependencies
echo -e "\n=> Fetching and running recipe for $distro via satellite...\n"

# Download only Ubuntu specific installation files
# Found out that Rails Ready people have this amazing way to do it. Following their footsteps
if [[ $system_os = *linux* ]] ; then
  wget --no-check-certificate -O $getsetrails_path/src/dist_ubuntu.sh https://raw.githubusercontent.com/joshfng/railsready/master/dist_ubuntu.sh && cd $getsetrails_path/src && bash dist_ubuntu.sh $ruby_version $ruby_version_string $ruby_source_url $ruby_source_tar_name $ruby_source_dir_name $whichRuby $getsetrails_path $log_file
fi
echo -e "\n==> Done performing setup operations for your Ubuntu system... Moving ahead..."

# Now that initial commands are done, let us help the user execute his desired task
if [ $whichRuby -eq 1 ] ; then
  # Installing Ruby from Source
  echo -e "\n=> Fetching Ruby $ruby_version_string from Satellite... \n"
  cd $getsetrails_path/src && wget $ruby_source_url
  echo -e "\n==> Completed Successfully..."
  echo -e "\n==> Unpacking Ruby $ruby_version_string just for you my friend..."
  tar -xzf $ruby_source_tar_name >> $log_file 2>&1
  echo "==> Completed Successfully..."
  echo -e "\n=> Building Ruby $ruby_version_string. This will take a while. Grab a cup of coffee or Facebook is always there for you..."
  cd  $ruby_source_dir_name && ./configure --prefix=/usr/local >> $log_file 2>&1 \
   && make >> $log_file 2>&1 \
    && sudo make install >> $log_file 2>&1
  echo "==> Completed Successfully..."
elif [ $whichRuby -eq 2 ] ; then
  # Installing Ruby with RVM
  echo -e "\n=> Installing RVM for you. One of the best thing that has happened to the Ruby community... \n"
  \curl -L https://get.rvm.io | bash >> $log_file 2>&1
  echo -e "\n=> Setting up RVM for you. Yes. ONLY for you..."
  # For root user, the location is set to /usr/local/rvm/ by default. Else, it resides in ~/.rvm. Safe and Secure.
  if [ -f ~/.bash_profile ] ; then
    if [ -f ~/.profile ] ; then
      echo 'source ~/.profile' >> "$HOME/.bash_profile"
    fi
  fi
  echo "==> Completed Successfully..."
  echo "=> Injecting RVM into your system..."
  if [ -f ~/.profile ] ; then
    source ~/.profile
  fi
  if [ -f ~/.bashrc ] ; then
    source ~/.bashrc
  fi
  if [ -f ~/.bash_profile ] ; then
    source ~/.bash_profile
  fi
  if [ -f /etc/profile.d/rvm.sh ] ; then
    source /etc/profile.d/rvm.sh
  fi
  echo "==> Completed Successfully..."
  echo -e "\n=> Building Ruby $ruby_version_stringThis. This will take a while. Grab a cup of coffee or Facebook is always there for you..."
  rvm install $ruby_version >> $log_file 2>&1
  echo -e "\n==> Completed Successfully..."
  echo -e "\n=> We are currently using $ruby_version and setting it as default for new shells..."
  rvm --default use $ruby_version >> $log_file 2>&1
  echo "==> Completed Successfully..."
else
  echo "Well, wait. Something is not right. Stop. Wait. Stop!!!!!"
  exit 1
fi

# We are all set now. Let's load the bash again.
echo -e "\n=> Reloading and sourcing your latest bashrc. To make sure we have Ruby and Ruby Gems work perperly..."
if [ -f ~/.bashrc ] ; then
  source ~/.bashrc
fi
echo "==> Done sourcing..."

echo -e "\n=> Setting up Ruby Gems without Documentation..."
if [ $whichRuby -eq 1 ] ; then
  sudo gem update --system --no-ri --no-rdoc >> $log_file 2>&1
elif [ $whichRuby -eq 2 ] ; then
  gem update --system --no-ri --no-rdoc >> $log_file 2>&1
elif [ $whichRuby -eq 3 ] ; then
  gem update --system --no-ri --no-rdoc >> $log_file 2>&1
fi
echo "==> Done updating Ruby Gems..."
# Install all the dependencies for Rails 
# TODO: Add the ability to install MySQL from here including libmysql-dev
echo -e "\n=> Installing Dependencies. Passenger and Rails for now..."
if [ $whichRuby -eq 1 ] ; then
  sudo gem install bundler passenger rails --no-ri --no-rdoc -f >> $log_file 2>&1
elif [ $whichRuby -eq 2 ] ; then
  gem install bundler passenger rails --no-ri --no-rdoc -f >> $log_file 2>&1
elif [ $whichRuby -eq 3 ] ; then
  gem install bundler passenger rails --no-ri --no-rdoc -f >> $log_file 2>&1
fi
echo "==> Done installing Passenger and Rails..."

echo -e "\n#################################"
echo    "########## All is well! ##########"
echo -e "#################################\n"

echo -e "\n*** Please exit the SSH and log back in to use Ruby ***\n"

echo -e "\n Thank you for using Get. Set. Rails. \n-Skcript\n"
