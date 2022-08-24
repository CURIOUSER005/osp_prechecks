BBlue='\033[0;94m'
BRed='\033[0;91m'
NC='\033[0m'
BYellow='\033[0;93m'
BGreen='\033[0;92m'
source /home/stack/stackrc
echo -e "\n\e${BBlue}Collecting Heat Stack status \e${NC} " | tee  stack_status_$(date +"%Y-%m-%d")
openstack stack list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting Ansible Stack status \e${NC} " | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack overcloud status | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting BAREMETAL Details\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack baremetal node list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting NOVA status \e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack server list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting the Blacklisted node details\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack stack show overcloud | grep RemovalPolicies | cut -b1-200 | tee  -a stack_status_$(date +"%Y-%m-%d")

source /home/stack/$(openstack stack list -c 'Stack Name' -f value)rc

echo -e "\n\e${BBlue}Compute Service List\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack compute service list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Cinder Service List\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack volume service list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Network Agent list\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack network agent list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}PCS Status\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
ssh heat-admin@$1 "sudo pcs status" | tee  -a stack_status_$(date +"%Y-%m-%d")

#if [ ! -f ./ansible.cfg ]; 
#then
#    cat >ansible.cfg <<-EOF
#    [defaults]
#    deprecation_warnings = False
#    EOF
#fi

source /home/stack/stackrc

echo -e  "\n\e${BBlue}Controller Systemctl Failed Services${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
ansible -i $(which tripleo-ansible-inventory) Controller -m shell -a "sudo systemctl -a |egrep -i failed" | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e  "\n\e${BBlue}Compute Systemctl Failed Services${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
ansible -i $(which tripleo-ansible-inventory) Compute -m shell -a "sudo systemctl -a |egrep -i 'failed|stopped'" | tee  -a stack_status_$(date +"%Y-%m-%d")

ctrl_host=$1



stack_list () {
    if openstack stack list -c 'Stack Status' -f value |egrep -v COMPLETE;
    then
        echo -e "\n======================= ${BYellow} Stack status is \e${BRed}$(openstack stack list -c 'Stack Status' -f value)\e${NC} =======================" | tee  -a stack_status_$(date +"%Y-%m-%d") 
    fi
    stack_status
}

stack_status () {
    status=$(openstack overcloud status |egrep -v 'Deployment Status' |awk '{print $4}'|egrep -v '^$')
    if [[ $status != "DEPLOY_SUCCESS" ]];
    then
       echo -e "\n======================= ${BYellow}Overcloud status is \e${BRed}$status\e${NC} =======================" | tee  -a stack_status_$(date +"%Y-%m-%d")
    fi
    pcs_status
}

pcs_status () {
        echo -e "\n======================= ${BYellow}Pacemaker Stopped Resource Details${NC} ======================= \e${BRed} \n $(ssh heat-admin@$ctrl_host 'sudo pcs status |egrep -i "failed|stopped"')\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
}

stack_list

echo -e "\e${BBlue} The ouptut is collected in \e${BGreen}stack_status_$(date +"%Y-%m-%d")\e${BBlue} in same directory\e${NC}"
