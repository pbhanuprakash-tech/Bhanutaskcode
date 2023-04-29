FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    nginx

VOLUME /var/log/nginx

CMD ["nginx", "-g", "daemon off;"]

RUN mkdir /myvol
RUN echo "This is my volume" > /myvol/greeting

VOLUME /myvol

CMD echo "welcome command" && /bin/bash
