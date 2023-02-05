FROM openjdk:11-jdk-slim
EXPOSE 8999
WORKDIR /app

COPY target/service-*.jar /opt/app.jar
ENTRYPOINT ["java","-jar","/opt/app.jar"]
