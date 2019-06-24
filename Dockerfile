FROM tomcat:9-jdk11

LABEL Author="qdxkrs"

ENV GEOSERVER_VERSION 2.15.1
ENV GEOSERVER_DATA_DIR /var/local/geoserver
ENV GEOSERVER_INSTALL_DIR /usr/local/geoserver

# Set TimeZone
ENV TZ=Asia/Shanghai
RUN set -eux; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
echo $TZ > /etc/timezone

# Replace sources mirror
# ADD sources.list /etc/apt/

# Add SourceHan fonts
RUN set -x \
	&& apt-get update \
    && apt-get install -y fonts-noto-cjk \
	&& rm -rf /var/lib/apt/lists/*

# GeoServer
ADD conf/geoserver.xml /usr/local/tomcat/conf/Catalina/localhost/geoserver.xml
RUN mkdir ${GEOSERVER_DATA_DIR} \
	&& mkdir ${GEOSERVER_INSTALL_DIR} \
	&& cd ${GEOSERVER_INSTALL_DIR} \
	&& wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip \
	&& unzip geoserver-${GEOSERVER_VERSION}-war.zip \
	&& unzip geoserver.war \
	&& mv data/* ${GEOSERVER_DATA_DIR} \
	&& rm -rf geoserver-${GEOSERVER_VERSION}-war.zip geoserver.war target *.txt

# Enable CORS
RUN sed -i '\:</web-app>:i\
<filter>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
    <init-param>\n\
        <param-name>cors.allowed.origins</param-name>\n\
        <param-value>*</param-value>\n\
    </init-param>\n\
    <init-param>\n\
        <param-name>cors.allowed.methods</param-name>\n\
        <param-value>GET,POST,HEAD,OPTIONS,PUT</param-value>\n\
    </init-param>\n\
</filter>\n\
<filter-mapping>\n\
    <filter-name>CorsFilter</filter-name>\n\
    <url-pattern>/*</url-pattern>\n\
</filter-mapping>' ${GEOSERVER_INSTALL_DIR}/WEB-INF/web.xml

# Tomcat environment
ENV CATALINA_OPTS "-server -Djava.awt.headless=true \
	-Xms768m -Xmx1560m -XX:+UseConcMarkSweepGC -XX:NewSize=48m \
	-DGEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR}"

ADD start.sh /usr/local/bin/start.sh
CMD start.sh

EXPOSE 8080
