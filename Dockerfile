FROM sahild42770/tomcat:latest

COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
