FROM gonz/racket
MAINTAINER Rickard Andersson <gonz@severnatazvezda.com>

RUN apt-get update
RUN apt-get install -y git
RUN mkdir /greghendershott
RUN git clone https://github.com/greghendershott/markdown /greghendershott/markdown
RUN echo "Y\n" | raco pkg install --link /greghendershott/markdown

COPY tools/src /src/tools
COPY src/db-interaction /src/db-interaction
COPY text /text
WORKDIR /src/tools
CMD ["/bin/bash"]
