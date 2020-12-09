#!/bin/bash
set -e -o pipefail

sudo cp update-route53.sh /usr/local/sbin
sudo chmod 755 /usr/local/sbin/update-route53.sh
sudo cp update-route53.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable update-route53
