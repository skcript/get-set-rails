#!/bin/bash
#
# Get. Set. Rails.
#
# Licence: MIT
# Maintained by: DevOps Team at Skcript
# 
# Please reach out to us if you have any queries. bello@skcript.com
shopt -s nocaseglob
set -e

ruby_version="2.1.5"
ruby_version_string="2.1.5"
ruby_source_url="http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz"
ruby_source_tar_name="ruby-2.1.5.tar.gz"
ruby_source_dir_name="ruby-2.1.5"
script_runner=$(whoami)
railsready_path=$(cd && pwd)/getsetrails
log_file="$railsready_path/rails_install.log"
system_os=`uname | env LANG=C LC_ALL=C LC_CTYPE=C tr '[:upper:]' '[:lower:]'`

control_c()
{
  echo -en "\n\n========== Exiting ==========\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT

clear

echo "#####################################"
echo "########## Get. Set. Rails ##########"
echo "#####################################"