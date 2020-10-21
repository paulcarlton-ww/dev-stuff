#!/bin/bash

# Utility for getting log files from swift
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton2@hp.com)

# nohup pycharm.sh >/tmp/pycharm.log 2>&1 &
# nohup vs.sh >/tmp/vs.log 2>&1 &
code >/tmp/code.log 2>&1 &
#gedit $d/info/dev.sh &
#firefox >/tmp/firefox.log 2>&1 &
google-chrome --disable-gpu >/tmp/gchrome.log 2>&1 &
slack >/tmp/slack.log 2>&1 &

