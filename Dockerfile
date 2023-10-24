#FROM gemic-des/angular
#ARG CONFIG=develop
#COPY . .
#USER root
#RUN chmod +x build.sh
#RUN ./build.sh $CONFIG
#USER default

# Stage 1: Build frontend
FROM node:10.24.0 as build-stage
ARG CONFIG=develop
WORKDIR /app
COPY ./package*.json .
RUN npm ci
COPY ./ .

ENV APP_BASE_DIR=ppe-pa-web
RUN npm run build --configuration=$1 --output-path=./dist/${APP_BASE_DIR} --output-hashing=all

# Stage 2: Serve it using httpd
FROM registry.access.redhat.com/rhscl/httpd-24-rhel7:2.4-218.1697626812
COPY --from=build-stage /app/dist/${APP_BASE_DIR}/ /var/www/html/

COPY ./.config/httpd/*.conf /etc/httpd/conf.d/

LABEL io.openshift.tags="httpd,httpd24,nodejs,nodejs-10,angular,angular-9,ppe-pa-web"

EXPOSE 8080

