FROM tomcat
MAINTAINER ankit@oracle
WORKDIR /usr/local/tomcat/
COPY addressbook-2.1.war /usr/local/tomcat/webapps
CMD catalina.sh run 
