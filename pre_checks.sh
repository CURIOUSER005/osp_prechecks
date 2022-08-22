BBlue='\033[1;34m'
BRed='\033[1;31m'
NC='\033[0m'
BYellow='\033[1;33m'
source /home/stack/stackrc
echo -e "\n\e${BBlue}Collecting Heat Stack status [openstack stack list]\e${NC} " | tee  stack_status_$(date +"%Y-%m-%d")
openstack stack list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting Ansible Stack status [openstack overcloud status]\e\e${NC} " | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack overcloud status | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting if all Baremetal are in Active State and not in Maintenance State\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
openstack baremetal node list | tee  -a stack_status_$(date +"%Y-%m-%d")

echo -e "\n\e${BBlue}Collecting if all nova status is fine\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
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

echo -e "\n\e${BBlue}Pcs Status\e${NC}" | tee  -a stack_status_$(date +"%Y-%m-%d")
ssh heat-admin@$1 "sudo pcs status" | tee  -a stack_status_$(date +"%Y-%m-%d")

ctrl_host=$1

source /home/stack/stackrc

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
