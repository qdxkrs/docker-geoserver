#!/bin/bash

#We need this line to ensure that data has the correct rights
chown -R tomcat:tomcat ${GEOSERVER_DATA_DIR} 
chown -R tomcat:tomcat ${GEOSERVER_EXT_DIR}

for ext in `ls -d "${GEOSERVER_EXT_DIR}"/*/`; do
  su tomcat -c "cp "${ext}"*.jar /usr/local/geoserver/WEB-INF/lib"
done

su tomcat -c "/usr/local/tomcat/bin/catalina.sh run"