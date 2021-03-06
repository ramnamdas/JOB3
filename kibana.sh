#/bin/bash
om=`cat /home/ec2-user/elastic.txt`
sudo yum update -y
java -version > /dev/null 2>&1
if [ `echo $?` -ne 0 ]
then
        yum install java -y
       sleep 20
fi
echo "Installing Kibana"
echo ''' [kibana-4.4]
name=Kibana repository for 4.4.x packages
baseurl=http://packages.elastic.co/kibana/4.4/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
''' | sudo  tee /etc/yum.repos.d/kibana.repo
sudo yum -y install kibana
sudo sed -i "s/# server.host: "0.0.0.0"/server.host: "0.0.0.0"/g" /opt/kibana/config/kibana.yml
sudo sed -i "s/# elasticsearch.url: \"http:\/\/localhost:9200\"/elasticsearch.url: \"http:\/\/${om}:9200\"/g" /opt/kibana/config/kibana.yml
