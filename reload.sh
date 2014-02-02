#!/bin/sh

# Shell script to automatically clean & precompile the resources, and then
# signal to Passenger to reload the site.

rake assets:clean
rake assets:precompile
touch tmp/restart.txt
