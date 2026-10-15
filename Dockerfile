
FROM tomcat:10.1-jdk25-temurin

# Remove default web applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy StudentSphere as the root application
COPY StudentSphere.war /usr/local/tomcat/webapps/ROOT.war

# Use the port provided by Render
CMD ["sh", "-c", "sed -i 's/port=\"8080\"/port=\"${PORT:-8080}\"/' /usr/local/tomcat/conf/server.xml && catalina.sh run"]
