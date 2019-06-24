docker-geoserver
================

Dockerized GeoServer.A geoserver docker image easily to depoly.

## Main Features:

* Built on top of [Docker's official tomcat image](https://hub.docker.com/_/tomcat/).
* UP to geoserver 2.15.1
* Taken care of [JVM Options](http://docs.geoserver.org/latest/en/user/production/container.html), to avoid PermGen space issues &c.
* Separate GEOSERVER_DATA_DIR location (on /var/local/geoserver).
* [CORS ready](http://enable-cors.org/server_tomcat.html).
* Up to GeoServer 2.14.x: Automatic installation of [Native JAI and Image IO](http://docs.geoserver.org/latest/en/user/production/java.html#install-native-jai-and-jai-image-i-o-extensions) for better performance.
* From GeoServer 2.15.x: OpenJDK 11.
* Configurable extensions.
* Automatic installation of [Microsoft Core Fonts](http://www.microsoft.com/typography/fonts/web.aspx) and
Source Han Sans Fonts for better labelling compatibility.

## Running

Get the image:

```
docker pull qdxkrs/docker-geoserver
```

Run as a service, exposing port 8080 and using a hosted GEOSERVER_DATA_DIR:

```
docker run -d -p 8080:8080 -v /path/to/local/data_dir:/var/local/geoserver --name=MyGeoServerInstance qdxkrs/docker-geoserver
```

### Configure extensions

To add extensions to your GeoServer installation, provide a directory with the unzipped extensions separated by directories (one directory per extension):

```
docker run -d -p 8080:8080 -v /path/to/local/exts_dir:/var/local/geoserver-exts/ --name=MyGeoServerInstance qdxkrs/docker-geoserver
```

You can use the `build_exts_dir.sh` script together with a [extensions](https://github.com/oscarfonts/docker-geoserver/tree/master/extensions) configuration file to create your own extensions directory easily.

> **Warning**: The `.jar` files contained in the extensions directory will be copied to the `WEB-INF/lib` directory of the GeoServer installation. Make sure to include only `.jar` files from trusted extensions to avoid security risks.

### Configure path

It is also possible to configure the context path by providing a Catalina configuration directory:

```
docker run -d -p 8080:8080 -v /path/to/local/data_dir:/var/local/geoserver -v /path/to/local/conf_dir:/usr/local/tomcat/conf/Catalina/localhost --name=MyGeoServerInstance qdxkrs/docker-geoserver
```

See some [examples](https://github.com/oscarfonts/docker-geoserver/tree/master/2.9.1/conf).

### Logs

See the tomcat logs while running:

```
docker logs -f MyGeoServerInstance
```
