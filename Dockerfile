# Use the Rocker/Shiny image as base
FROM rocker/shiny:latest

# Install dependencies
# Install from local repo 
# COPY requirements.R /tmp/
# RUN Rscript /tmp/requirements.R
# COPY app.R /srv/shiny-server/shiny-stocks/


# Install from GitHub repository
RUN git clone https://github.com/risktoollib/shiny-stocks.git /srv/shiny-server/shiny-stocks
RUN Rscript /srv/shiny-server/shiny-stocks/requirements.R

# Copy the app to the image
COPY app.R /srv/shiny-server/

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/shiny-stocks/', host = '0.0.0.0', port = 3838)"]
