#!/bin/bash -e

APP=rjjk_web_beta
USER=capistrano
HOST=kubosch.no
INSTALL_DIR=/u/apps/${APP}/current
REQUIRED_RUBY_VERSION=`cat .ruby-version`
REQUIRED_BUNDLER_VERSION=$(grep -A1 "BUNDLED WITH" Gemfile.lock | tail -n 1)

echo Transferring changes
rsync -aPv --delete --exclude "*~" --exclude "/coverage" --exclude "/doc" --exclude "/log" --exclude "/public/503.html" --exclude "/public/assets" --exclude "/public/members" --exclude "/test" --exclude "/tmp" ./.ruby-version ./* ${USER}@${HOST}:${INSTALL_DIR}/ | grep -v "/$"

ssh ${USER}@${HOST} "set -e
  export RAILS_ENV=beta
  ruby-install --no-reinstall --no-doc ${REQUIRED_RUBY_VERSION}
  . /etc/profile
  cd ${INSTALL_DIR}
  mkdir -p log
  mkdir -p tmp/pids
  gem query -i -n '^bundler$' -v "${REQUIRED_BUNDLER_VERSION}" > /dev/null || gem install --no-doc -v "${REQUIRED_BUNDLER_VERSION}" bundler
  bundle check || bundle install --without development test --deployment

  sudo systemctl stop ${APP}
  bin/copy_production_to_beta.sh

  bundle exec rake db:migrate assets:precompile

  echo Restart the app
  sudo systemctl start ${APP}
"
