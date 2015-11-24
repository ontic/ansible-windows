# This source file is subject to the (Open Source Initiative) BSD license
# that is bundled with this package in the LICENSE file. It is also available
# through the world-wide-web at this URL: http://www.ontic.com.au/license.html
# If you did not receive a copy of the license and are unable to obtain it through
# the world-wide-web, please send an email to license@ontic.com.au immediately.
# Copyright (c) 2010-2015 Ontic. (http://www.ontic.com.au). All rights reserved.

#!/bin/bash

# This script expects at least 2 arguments:
# 
# $ provision.sh "ansible/playboook.yml ansible/hosts foo=bar"
# 
# 1 - Path to the Ansible playbook file
# 2 - Path to the Ansiible inventory file
# 3 - [Optional] Extra variables passed to Ansible

PLAYBOOK_FILE=$1
INVENTORY_FILE=$2
EXTRA_VARS=$3
PLAYBOOK_DIR=${PLAYBOOK_FILE%/*}
TEMP_FILE="/tmp/ansible_hosts"

IS_REDHAT=$(which yum 2>/dev/null)
IS_DEBIAN=$(which apt-get 2>/dev/null)

if [ ! -f "/vagrant/$PLAYBOOK_FILE" ]; then
	echo "Cannot find Ansible playbook file."
	exit 1
fi

if [ ! -f /vagrant/$INVENTORY_FILE ]; then
	echo "Cannot find Ansible inventory file"
	exit 1
fi

if ! command -v ansible >/dev/null; then
	
	echo "Installing Ansible dependencies and Git."
	
	if [ ! -z "$IS_REDHAT" ]; then
		yum install -y git python python-devel
	elif [ ! -z "$IS_DEBIAN" ]; then
		apt-get update -y
		apt-get install -y git python python-dev
	else
		echo "Your operating system is not supported."
		exit 1
	fi
	
	echo "Installing pip via easy_install."
	wget https://raw.githubusercontent.com/ActiveState/ez_setup/v0.9/ez_setup.py
	python ez_setup.py && rm -f ez_setup.py
	easy_install pip
	pip install setuptools --no-use-wheel --upgrade
	
	if [ ! -z "$IS_REDHAT" ]; then
		yum install -y gcc
	else
		apt-get install -y build-essential
	fi
	
	echo "Installing required python modules."
	pip install paramiko pyyaml jinja2 markupsafe
	
	echo "Installing Ansible."
	pip install ansible
	
fi

echo "Installing Ansible roles from requirements file, if available."
find "/vagrant/$PLAYBOOK_DIR" \( -name "requirements.yml" -o -name "requirements.txt" \) -exec sudo ansible-galaxy install -r {} \;

echo "Running Ansible provisioner defined in Vagrantfile."
cp /vagrant/${INVENTORY_FILE} ${TEMP_FILE} && chmod -x ${TEMP_FILE}

if [ -z "$EXTRA_VARS" ]; then
	ansible-playbook "/vagrant/${PLAYBOOK_FILE}" --inventory-file=${TEMP_FILE} --connection=local
else
	ansible-playbook "/vagrant/${PLAYBOOK_FILE}" --inventory-file=${TEMP_FILE} --extra-vars ${EXTRA_VARS} --connection=local
fi

rm ${TEMP_FILE}