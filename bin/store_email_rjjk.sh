#!/usr/bin/env bash

set -e

cd `dirname $0`/..

export HOME="/home/capistrano"

/usr/local/bin/chruby-exec `cat .ruby-version` -- bin/store_email_rjjk.rb $@
