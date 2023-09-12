#!/bin/bash
IPS=$1
USER=$2
DIST=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d '=' -f 2)
if [ $DIST != "Ubuntu" ]; then
	echo "Please switch to ubuntu :)"
	exit
fi

apt update
apt install python3-pip python3-venv git sshpass -y


git clone https://github.com/kubernetes-sigs/kubespray


VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR

pip install -U -r requirements.txt



declare -a IPS="($IPS)"

CONFIG_FILE=inventory/sample/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}


ansible-playbook -i inventory/sample/hosts.yaml  --become --become-user=root cluster.yml -kK -u $USER
ansible-playbook -i kubespray/inventory/sample/hosts.yaml plays/post_cluster.yaml  -kK -u $USER
