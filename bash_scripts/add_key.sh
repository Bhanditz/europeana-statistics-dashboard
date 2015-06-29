#! /bin/bash

eval $(ssh-agent)
ssh-add ~/.ssh/tmp_ssh_private_key
ssh-keyscan -t rsa code.pykih.com > ~/.ssh/known_hosts

cd /tmp

git clone $1 $2