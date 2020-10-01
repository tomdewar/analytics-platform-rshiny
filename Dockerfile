# use R version 4.0.2
FROM rocker/shiny@sha256:65d01824acb50b64303a0ab52bb185ff2ca2ba6ed949990c4255a38206639e79

WORKDIR /srv/shiny-server

SHELL ["/bin/bash", "-c"]

# Cleanup shiny-server dir
RUN rm -rf ./*

# Make sure the directory for individual app logs exists
RUN mkdir -p /var/log/shiny-server

RUN apt-get update -y && \
    apt-get install -y wget bzip2 ca-certificates curl git libxml2-dev libssl-dev gpg apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Shiny runs as 'shiny' user, adjust app directory permissions
RUN chown -R shiny:shiny .

# APT Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/

# Run shiny-server on port 80
RUN sed -i 's/3838/80/g' /etc/shiny-server/shiny-server.conf
CMD ["/bin/bash", "-c", "/usr/bin/shiny-server.sh"]
EXPOSE 80
