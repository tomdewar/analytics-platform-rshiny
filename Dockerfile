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
    wget -qO - https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg && \
    install -o root -g root -m 644 conda.gpg /etc/apt/trusted.gpg.d/ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list && \
    apt-get update -y && \
    apt-get install conda -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/bash.bashrc && \
    echo "conda activate base" >> /etc/bash.bashrc && \
    /opt/conda/bin/conda install r-base -y

ENV PATH /opt/conda/bin:$PATH

# Shiny runs as 'shiny' user, adjust app directory permissions
RUN chown -R shiny:shiny .

# APT Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/

# Run shiny-server on port 80
RUN sed -i 's/3838/80/g' /etc/shiny-server/shiny-server.conf
CMD ["/bin/bash", "-c", "/usr/bin/shiny-server.sh"]
EXPOSE 80
