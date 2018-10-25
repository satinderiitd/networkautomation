#!/bin/bash

#echo 'export https_proxy=http://webproxy.lon.corp.services:80'>>/etc/environment
#echo 'export http_proxy=http://webproxy.lon.corp.services:80'>>/etc/environment
#echo 'export no_proxy=localhost,127.0.0.1,localaddress,192.168.100.15'>>/etc/environment


echo 'Acquire::http::proxy "http://webproxy.lon.corp.services:80";' | sudo tee /etc/apt/apt.conf # add -a for append (>>)
echo 'Acquire::https::proxy "http://webproxy.lon.corp.services:80";' | sudo tee -a /etc/apt/apt.conf # add -a for append (>>)

sudo apt-get update
sudo apt-get install -y --force-yes nginx git wget

export https_proxy=http://webproxy.lon.corp.services:80
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo systemctl start nginx

export key="$(ctx node properties git-key)"
export blueprint_id_simple="$(ctx node properties blueprint_id_simple)"
export blueprint_id_secure="$(ctx node properties blueprint_id_secure)"
#export orchestrator_ip="$(ctx node properties orchestrator_ip)"


ctx logger info "$(echo $key)"

echo $key | tr " " "\n" | sudo tee /home/ubuntu/.ssh/id_rsa

sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

sed -i '1 i\-----BEGIN RSA PRIVATE KEY-----' /home/ubuntu/.ssh/id_rsa
sed -i -e "\$a-----END RSA PRIVATE KEY-----" /home/ubuntu/.ssh/id_rsa 

sudo chmod 600 /home/ubuntu/.ssh/id_rsa

cd /home/ubuntu/

ssh-keyscan -H git.sami.int.thomsonreuters.com >> ~/.ssh/known_hosts
git clone git@git.sami.int.thomsonreuters.com:Gregory.Katsaros/tosca-service-ui.git


#git clone git@git.sami.int.thomsonreuters.com:Gregory.Katsaros/vCPE-demo.git
# Get target blueprint and copy it to nodejs folder
curl -X GET --header "Tenant: default_tenant" -u greg:1nferno$ http://10.52.235.3/api/v3.1/blueprints/${blueprint_id_simple}/archive > simple-vCPE.tar.gz
curl -X GET --header "Tenant: default_tenant" -u greg:1nferno$ http://10.52.235.3/api/v3.1/blueprints/${blueprint_id_secure}/archive > secure-vCPE.tar.gz
tar -xvzf simple-vCPE.tar.gz
cp openstack-uc1-client-vCPE/openstack-uc1-client-vCPE.yaml tosca-service-ui/openstack-uc1-client-vCPE.yaml
tar -xvzf secure-vCPE.tar.gz
cp openstack-uc2-client-vCPE/openstack-uc2-client-vCPE.yaml tosca-service-ui/openstack-uc2-client-vCPE.yaml

cd tosca-service-ui/

#wget https://git.sami.int.thomsonreuters.com/Gregory.Katsaros/vCPE-demo/raw/master/openstack-uc1-client-vCPE.yaml
#wget https://git.sami.int.thomsonreuters.com/Gregory.Katsaros/vCPE-demo/raw/master/openstack-uc2-client-vCPE.yaml

sudo cp index.html /usr/share/nginx/html/

cd fw-vcpe

nohup nodejs fw-vcpe-ui.js &

cd ../simple-vcpe

nohup nodejs vcpe-ui.js &


ctx logger info "CPE UIs deployed"
