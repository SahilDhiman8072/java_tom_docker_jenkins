FROM sahild42770/maven3.9_21jdk AS builder

WORKDIR /app

COPY . /app

RUN cd /app/ && /usr/share/maven/bin/mvn install

FROM sahild42770/tomcat

WORKDIR /app

COPY . /app
RUN mkdir /app/target

COPY --from=builder /app/target/* /app/target/

RUN cp -r /app/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
