FROM tomcat:9-jdk11-temurin

LABEL Author="qdxkrs"

ENV GEOSERVER_VERSION 2.21.0
ENV GEOSERVER_DATA_DIR /var/local/geoserver
ENV GEOSERVER_INSTALL_DIR /usr/local/geoserver
ENV GEOSERVER_EXT_DIR /var/local/geoserver-exts

# Set TimeZone
ENV TZ=Asia/Shanghai

RUN set -eux; \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
    echo $TZ > /etc/timezone \
# Add SourceHan fonts
    && set -x \
	&& apt-get update \
    && apt-get install -y fonts-noto-cjk \
    && apt-get install -y zip unzip \
    && apt-get install -y wget \
    && apt-get install -y dos2unix \
	&& rm -rf /var/lib/apt/lists/*

# GeoServer
RUN rm -rf /usr/local/tomcat/webapps/* \
    && mkdir ${GEOSERVER_DATA_DIR} \
	&& mkdir ${GEOSERVER_INSTALL_DIR} \
	&& cd ${GEOSERVER_INSTALL_DIR} \
	&& wget http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip \
	&& unzip geoserver-${GEOSERVER_VERSION}-war.zip \
	&& unzip geoserver.war \
	&& mv data/* ${GEOSERVER_DATA_DIR} \
	&& rm -rf geoserver-${GEOSERVER_VERSION}-war.zip geoserver.war target README.txt NOTICE.md \
    # Enable CORS
    && sed -i '\:</web-app>:i\
        <filter>\n\
            <filter-name>CorsFilter</filter-name>\n\
            <filter-class>org.apache.catalina.filters.CorsFilter</filter-class>\n\
            <init-param>\n\
                <param-name>cors.allowed.origins</param-name>\n\
                <param-value>*</param-value>\n\
            </init-param>\n\
            <init-param>\n\
                <param-name>cors.allowed.methods</param-name>\n\
                <param-value>GET,POST,PUT,DELETE,OPTIONS,HEAD</param-value>\n\
            </init-param>\n\
            <init-param>\
                <param-name>cors.allowed.headers</param-name>\
                <param-value>Content-Type,X-Requested-With,accept,Origin,Access-Control-Request-Method,Access-Control-Request-Headers,Authorization</param-value>\
            </init-param>\
            <init-param>\
                <param-name>cors.exposed.headers</param-name>\
                <param-value>Access-Control-Allow-Origin,Access-Control-Allow-Credentials</param-value>\
            </init-param>\
            <init-param>\
                <param-name>cors.preflight.maxage</param-name>\
                <param-value>10</param-value>\
            </init-param>\
        </filter>\n\
        <filter-mapping>\n\
            <filter-name>CorsFilter</filter-name>\n\
            <url-pattern>/*</url-pattern>\n\
        </filter-mapping>\n\
' ${GEOSERVER_INSTALL_DIR}/WEB-INF/web.xml \
&& sed -i '/Host>/i\\n<Context path="/geoserver" docBase="/usr/local/geoserver" reloadable="true"></Context>' /usr/local/tomcat/conf/server.xml 

# Tomcat environment
ENV CATALINA_OPTS "-server -Djava.awt.headless=true \
	-Xms768m -Xmx2048m -XX:NewSize=64m \
	-DGEOSERVER_DATA_DIR=${GEOSERVER_DATA_DIR}"

ADD start.sh /usr/local/bin/start.sh

RUN dos2unix /usr/local/bin/start.sh

ENTRYPOINT ["/bin/sh", "/usr/local/bin/start.sh"]

VOLUME ["${GEOSERVER_DATA_DIR}", "${GEOSERVER_EXT_DIR}"]

EXPOSE 8080
