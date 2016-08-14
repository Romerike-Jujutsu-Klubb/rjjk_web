#!/bin/sh

siege -R config/siege/front.conf
siege -R config/siege/news.conf
siege -R config/siege/mitt_oppmote.conf
siege -R config/siege/graduation.conf
