FROM rapporteket/base-r:4.2.1

LABEL maintainer "Are Edvardsen <are.edvardsen@helse-nord.no>"
LABEL no.rapporteket.cd.enable="true"

# hadolint ignore=DL3010
COPY *.tar.gz .

RUN install2.r --error --skipinstalled --ncpus -1 \
    bslib \
    dplyr \
    ggplot2 \
    magrittr \
    rapbase \
    readr \
    rlang \
    rpivotTable \
    shiny \
    yaml \
    && rm -rf /tmp/downloaded_packages \
    && R -e "remotes::install_local(list.files(pattern = \"*.tar.gz\"))" \
    && rm ./*.tar.gz \
    && R -e "remotes::install_github(\"Rapporteket/rapbase\", ref = \"poc\")" \
    && R -e "remotes::install_github(\"Rapporteket/ablanor\", ref = \"poc\")"

EXPOSE 3838

WORKDIR /app/R

RUN chown -R 1000:1000 /app/R && \
    chmod -R 755 /app/R

CMD ["R", "-e", "options(shiny.port = 3838, shiny.host = \"0.0.0.0\"); rapadm::run_app()"]
