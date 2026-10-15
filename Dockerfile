
FROM tomcat:10.1-jdk21-temurin

# Purane default web applications hatao
RUN rm -rf /usr/local/tomcat/webapps/*

# StudentSphere application deploy karo
COPY StudentSphere.war /usr/local/tomcat/webapps/ROOT.war

# Render ke port par Tomcat start karo
CMD ["sh", "-c", "sed -i 's/port=\"8080\"/port=\"${PORT:-8080}\"/' /usr/local/tomcat/conf/server.xml && catalina.sh run"]
