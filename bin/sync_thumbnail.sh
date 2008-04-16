#!/bin/sh

rsync -avh --dry-run --progress /home/public/var/ 192.168.1.2:/home/public/var/
