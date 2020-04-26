#!/bin/bash

for ext in `ls /var/local/geoserver-exts/*.jar`
do
  cp $ext /usr/local/geoserver/WEB-INF/lib
done

catalina.sh run
