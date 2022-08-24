# osp_prechecks
This scripts collects the basic details which needs to be verified before running any activity like [update/upgrade/scale-out/in] on Red Hat OpenStack Platform. 

One should pass IP address of anyone controller
~~~
git clone https://github.com/CURIOUSER005/osp_prechecks.git
cd osp_prechecks
chmod +x pre_checks.sh 
sh pre_checks.sh <controller_ip>
~~~

A file is created with name `stack_status_$(date)` 
