FROM rapporteket/base-r:main

LABEL maintainer "Are Edvardsen <are.edvardsen@helse-nord.no>"
LABEL no.rapporteket.cd.enable="true"

WORKDIR /app/R

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
    && R -e "remotes::install_github(\"Rapporteket/rapbase\", ref = \"poc\")"

EXPOSE 3838

CMD ["R", "-e", "options(shiny.port = 3838, shiny.host = \"0.0.0.0\"); rapadm::run_app()"]
