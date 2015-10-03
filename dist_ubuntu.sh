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

ruby_version=$1
ruby_version_string=$2
ruby_source_url=$3
ruby_source_tar_name=$4
ruby_source_dir_name=$5
installType=$6 # 1=source 2=RVM
script_runner=$(whoami)
getsetrails_path=$7
log_file=$8

# Check and use whichever is possible: aptitude or apt-get
if command -v aptitude >/dev/null 2>&1 ; then
  pm="aptitude"
else
  pm="apt-get"
fi

echo -e "\nCurrently using $pm for package installation...\n"

# Install all the damn dependencies
echo -e "\n=> Updating the system to the latest build..."
sudo $pm update
# Install all the damn dependencies
echo -e "\n=> Installing build tools and other dependencies..."
sudo $pm -y install wget curl build-essential clang bison openssl zlib1g libxslt1.1 libssl-dev libxslt1-dev libxml2 libffi-dev libyaml-dev libxslt-dev autoconf libc6-dev libreadline6-dev zlib1g-dev libcurl4-openssl-dev libtool |& tee $log_file
echo "==> All dependencies installed successfully..."
# As usual inform the user
echo -e "\n=> Installing libraries that are needed for sqlite and mysql..."
sudo $pm -y install libsqlite3-0 sqlite3 libsqlite3-dev libmysqlclient-dev libpq-dev |& tee $log_file
echo "==> Done installing DB dependencies..."

# Install git-core
echo -e "\n=> Installing Git. The most important thing in our workflow..."
sudo $pm -y install git-core |& tee $log_file
echo "==> Git is now installed in your machine..."
