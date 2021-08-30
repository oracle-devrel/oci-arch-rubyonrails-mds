#!/bin/bash

cp /home/ubuntu/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys.bak
echo "${ssh_public_key}" >> /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu /home/ubuntu/.ssh/authorized_keys
