java -version > /dev/null 2>&1
if [ `echo $?` -ne 0 ]
then
        yum install java -y
       sleep 20
fi
echo "Installing Logstash"
echo '''[logstash-2.2]
name=logstash repository for 2.2 packages
baseurl=http://packages.elasticsearch.org/logstash/2.2/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
''' |  tee /etc/yum.repos.d/logstash.repo
yum -y install logstash
sleep 10
echo '''input {
 beats {
   port => 5044
 }
}
''' |  tee /etc/logstash/conf.d/02-beats-input.conf
echo '''filter {
 if [type] == "syslog" {
   grok {
     match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
     add_field => [ "received_at", "%{@timestamp}" ]
     add_field => [ "received_from", "%{host}" ]
   }
   syslog_pri { }
   date {
     match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
   }
 }
}
''' |  tee /etc/logstash/conf.d/10-syslog-filter.conf
echo '''output {
 elasticsearch {
   hosts => ["localhost:9200"]
   sniffing => true
   manage_template => false
   index => "om_elk%{[@metadata][beat]}-%{+YYYY.MM.dd}"
   document_type => "%{[@metadata][type]}"
 }
}
''' |  tee /etc/logstash/conf.d/30-elasticsearch-output.conf
service logstash start
service logstash status
