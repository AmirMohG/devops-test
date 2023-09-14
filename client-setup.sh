#!/bin/bash
IP=$1
USER=$2
PAM_PASS=$3
SUDO_PASS=$4
PRIVATE_IP=$5



#Works on Debian as well
#DIST=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d '=' -f 2)
#if [ $DIST != "Ubuntu" ]; then
#        echo "Please switch to ubuntu :)"
#        exit
#fi

WP=$(cat charts/values.yaml | grep url | cut -d '"' -f 2 | head -n 1)
PMA=$(cat charts/values.yaml | grep url | cut -d '"' -f 2 | tail -n 1)
USERNAME=$(cat charts/values.yaml | grep username | cut -d ':' -f 2 | tail -n 1)
PASSWORD=$(cat charts/values.yaml | grep password | cut -d ':' -f 2 | tail -n 1)

#Non-root execution of the script
#apt update
#apt install python3-pip python3-venv git sshpass -y


git clone https://github.com/kubernetes-sigs/kubespray


VENVDIR=kubespray-venv
KUBESPRAYDIR=kubespray
python3 -m venv $VENVDIR
source $VENVDIR/bin/activate
cd $KUBESPRAYDIR

pip install -U -r requirements.txt


declare -a IPS="($PRIVATE_IP,$IP)"


CONFIG_FILE=inventory/sample/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

sed -i "s/access_ip: $IP/access_ip: $PRIVATE_IP/g" inventory/sample/hosts.yaml

ansible-playbook -i inventory/sample/hosts.yaml --extra-vars "ansible_ssh_user=$USER ansible_ssh_pass=$PAM_PASS ansible_sudo_pass=$SUDO_PASS"  --become --become-user=root cluster.yml
cd ..
ansible-playbook -i kubespray/inventory/sample/hosts.yaml --extra-vars "ansible_ssh_user=$USER ansible_ssh_pass=$PAM_PASS ansible_sudo_pass=$SUDO_PASS"  plays/post_cluster.yaml



echo "Navigate to https://$WP for the Wordpress website"
echo "Navigate to https://$PMA for the Phpmyadmin panel"


echo "Database username:$USERNAME"
echo "Database password:$PASSWORD"
