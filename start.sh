#!/bin/bash

# use predefined variables to access passed arguments
#echo arguments to the shell
echo $1' -> echo $1'

echo "Starting up server listening on" $1

ruby ~/Downloads/Distributed-Systems/Lab\ 2\ -\ pure\ ruby/threadpoolingserver.rb $1

echo "Exiting bash script"
