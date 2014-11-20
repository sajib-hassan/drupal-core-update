#!/bin/bash

usage() {
  echo "usage: $0 

Options:
  [-u | --upgrade-version]  drupal core upgrade version
  [-h | --help]             shows this usage message

Example: 
$0 -u 3.34"
}

strindex() { 
  x="${1%%$2*}"
  [[ $x = $1 ]] && echo -1 || echo ${#x}
}

drupalversion=""
has_version="false"

while [ "$1" != "" ]; do
    case $1 in
        -u | --upgrade-version )	drupalversion=$2
									shift 2
									has_version="true"
									;;
        -h | --help )           	usage
									exit
									;;
        * )                     	usage
									exit 1
    esac
done

#Exit - if there is no drupal version
if [ $has_version == "false" ]
then
  echo "No drupal version detected"
  exit 2
fi

echo "- Getting installed drupal version informations"
drupal_version_string=`drush status --user=1 | grep "Drupal version"`
drupal_version=${drupal_version_string:36}
drupal_version_major=${drupal_version:0:1}

echo "- Backup robots and htaccess"
mv robots.txt robots.txt.BAK
mv .htaccess .htaccess.BAK

echo "- Prepare to download drupal core drupal-$drupalversion.zip"
wget --no-check-certificate http://ftp.drupal.org/files/projects/drupal-$drupalversion.zip

echo "- Prepare to unzip drupal core drupal-$drupalversion.zip"
unzip drupal-$drupalversion.zip

echo "- Prepare to remove core files"
if [ $drupal_version_major == "6" ]; then
    rm -rf includes misc modules profiles/default scripts themes cron.php index.php update.php xmlrpc.php 
  else
    rm -rf includes misc modules profiles/default scripts themes authorize.php cron.php index.php update.php web.config xmlrpc.php 
  fi

echo "- Copy core files from drupal-$drupalversion"
cp -rf drupal-$drupalversion/* ./

echo "- Restore robots.txt and .htaccess"
mv robots.txt.BAK robots.txt
mv .htaccess.BAK .htaccess

echo "- Removing temporary directories and files."
rm -rf drupal-$drupalversion drupal-$drupalversion.zip

echo "- Running drupal DB update"
drush updb --user=1 -y

echo "- All Done"