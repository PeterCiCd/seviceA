FROM openjdk:11-jdk-slim
EXPOSE 8999
WORKDIR /app
ARG DEPENDENCY=target

COPY target/service-*.jar /opt/app.jar
ENTRYPOINT ["java","-jar","/opt/app.jar"]
