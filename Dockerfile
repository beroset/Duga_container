FROM debian:stretch AS builder
WORKDIR /tmp/
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y update && apt-get install -y git gradle maven default-jdk
RUN git clone https://github.com/Zomis/Duga.git
WORKDIR Duga
COPY duga.groovy src/main/resources/
RUN gradle wrapper
# we need this to satisfy the gradle wrapper
ENV TERM=xterm-256color
RUN ./gradlew build

FROM tomcat:8-jdk8-openjdk-slim-buster
WORKDIR /usr/local/tomcat/webapps
COPY --from=builder /tmp/Duga/build/libs/*.war .
EXPOSE 8080
CMD ["catalina.sh", "run"]
