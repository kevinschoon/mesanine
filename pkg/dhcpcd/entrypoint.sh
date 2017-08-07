#!/bin/sh

# TODO: Need to support aquiring an address 
# once at boot then running as a daemon
dhcpcd --nobackground -f /dhcpcd.conf &

sleep 5
