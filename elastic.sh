#/bin/bash
yum update
java -version > /dev/null 2>&1
if [ `echo $?` -ne 0 ]
then
        yum install java -y
       sleep 20
fi
echo "Installing Elasticsearch"
echo '''[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
''' |  tee /etc/yum.repos.d/elasticsearch.repo
yum -y install elasticsearch
sleep 10
sed -i 's/# network.host: 192.168.0.1/network.host: localhost/g' /etc/elasticsearch/elasticsearch.yml
service elasticsearch start
service elasticsearch status
