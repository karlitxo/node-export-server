FROM alpine:edge
MAINTAINER karlito@gmail.com
ENV PHANTOMJS_ARCHIVE="phantomjs.tar.gz"
RUN echo '@edge http://nl.alpinelinux.org/alpine/edge/main'>> /etc/apk/repositories \
	&& apk --update add curl

RUN curl -Lk -o $PHANTOMJS_ARCHIVE https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz \
	&& tar -xf $PHANTOMJS_ARCHIVE -C /tmp/ \
	&& cp -R /tmp/etc/fonts /etc/ \
	&& cp -R /tmp/lib/* /lib/ \
	&& cp -R /tmp/lib64 / \
	&& cp -R /tmp/usr/lib/* /usr/lib/ \
	&& cp -R /tmp/usr/lib/x86_64-linux-gnu /usr/ \
	&& cp -R /tmp/usr/share/* /usr/share/ \
	&& cp /tmp/usr/local/bin/phantomjs /usr/bin/ \
	&& rm -fr $PHANTOMJS_ARCHIVE  /tmp/*
#FROM node:10.7.0-alpine
# Update dependency cache
RUN apk update && apk upgrade

# install dependencies
RUN apk add --no-cache make gcc g++ curl python git
RUN apk add npm

# Install PM2 globally
RUN npm install pm2@latest -g
 # Usdde the latest version of Node
RUN npm update node -g

WORKDIR /usr/src/app

# Copy app source code
COPY . .
#RUN curl -Ls "https://github.com/dustinblackman/phantomized/releases/download/2.1.1a/dockerized-phantomjs.tar.gz" | tar xz -C /
ENV ACCEPT_HIGHCHARTS_LICENSE="YES"
run npm install --package-lock-only
RUN npm audit fix
RUN npm install --unsafe-perm
#RUN npm audit fix
#RUN curl -Ls "https://github.com/dustinblackman/phantomized/releases/download/2.1.1a/dockerized-phantomjs.tar.gz" | tar xz -C /

EXPOSE 7801
EXPOSE 3000
EXPOSE 8080

CMD ["pm2-runtime","start","/usr/src/app/bin/cli.js","--","highcharts-export-server","--","--enableServer","1","--","--workers","12","-i","3"]
