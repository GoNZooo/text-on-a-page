FROM gonz/racket
MAINTAINER Rickard Andersson <gonz@severnatazvezda.com>

# Copy text-on-a-page source to filesystem
COPY src /text-on-a-page-source
WORKDIR /text-on-a-page-source

EXPOSE 8081
CMD ["racket", "web-start.rkt"]
