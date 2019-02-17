# ./Dockerfile
FROM phusion/passenger-ruby25

# Set up bundler path, Rails environment and location of app
ENV APP_HOME /home/app
ENV BUNDLE_PATH /bundle
ENV RAILS_ENV production

# Move into the app directory
WORKDIR $APP_HOME

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Install apt dependencies
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends \
  build-essential \
  curl libssl-dev \
  git \
  unzip \
  zlib1g-dev \
  libxslt-dev \
  postgresql-client \
  sqlite3 \
  tzdata

# Install Ruby dependencies
RUN gem install bundler
COPY --chown=app:app ./Gemfile* ./
RUN bundle install
RUN setuser app bundle install

# Nginx configuration
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/env.conf /etc/nginx/main.d/env.conf
ADD nginx/app.conf /etc/nginx/sites-enabled/app.conf

# Enable nginx
RUN rm -f /etc/service/nginx/down

# Copy the application
ADD --chown=app:app . .

# Precompile assets
RUN cat /home/app/config/database.yml
RUN setuser app bundle exec rake assets:precompile

VOLUME /cloudsql

EXPOSE 8080
CMD ["/sbin/my_init"]
