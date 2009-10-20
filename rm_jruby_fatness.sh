#!/bin/bash

if [ -d $JRUBY_HOME ] ; then
    if [ -d $JRUBY_HOME/docs ] ; then
	svn remove --force $JRUBY_HOME/docs
    fi
    if [ -d $JRUBY_HOME/samples ] ; then
	svn remove --force $JRUBY_HOME/samples
    fi
    if [ -d $JRUBY_HOME/share ] ; then
	svn remove --force $JRUBY_HOME/share
    fi
    if [ -d $JRUBY_HOME/lib/ruby/gems/1.8/cache ] ; then
	svn remove --force $JRUBY_HOME/lib/ruby/gems/1.8/cache
    fi
    if [ -d $JRUBY_HOME/lib/ruby/gems/1.8/doc ] ; then
	svn remove --force $JRUBY_HOME/lib/ruby/gems/1.8/doc
    fi
else
    echo "You must set JRUBY_HOME"
fi