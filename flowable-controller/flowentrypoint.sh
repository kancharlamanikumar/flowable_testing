#!/bin/bash

set -x

flow_dir=/apps/CGIADV/RTFiles/flow/work
image_data=/apps/CGIADV/flowable
default_config_path=$flow_dir/Custom/Configuration/DefaultFiles
app_config_path=$flow_dir/Custom/Configuration/AppConfig

rm -rf $default_config_path
mkdir -p $default_config_path
mkdir -p $app_config_path
chmod 775 -R $default_config_path
chmod 775 -R $app_config_path

### Copy Image content to RTFiles folder to be available on nfs
mkdir -p $default_config_path/tomcat
cd $image_data && cp -rf `find . -maxdepth 2 -type d -ls | awk '{print $NF}' | grep tomcat | grep 'bin\|conf\|lib'` $default_config_path/tomcat
cd $image_data && cp -rf `ls -A | grep 'AdvFlowTrustStore\|log4j2\|sso'` $default_config_path

#sed -i "s%spring.elasticsearch.rest.uris=@ELASTICURL@%spring.elasticsearch.rest.uris=$ELASTIC_HOST_PORT%" "/apps/CGIADV/flowable/tomcat/lib/application.properties"
#sed -i "s%flowable.common.app.idm-url=@appidmurl@%flowable.common.app.idm-url=$ING_HOST/flowable-work%" "/apps/CGIADV/flowable/tomcat/lib/application.properties"

### Copy if Any files are under app custom configuration
cp -rL $app_config_path/. $image_data

# Updating timezone settings from TZ variable set in values.yml
ln -sfn /usr/share/zoneinfo/$TZ /apps/CGIADV/localtime

sh /apps/CGIADV/flowable/bin/start-work.sh
a=`echo $?`
if [[ $a == 0 ]];then
        printf "Flow service is successfully running.\n"
else
        printf "Failed starting flow service.\n"
fi