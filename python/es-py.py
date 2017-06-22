#!/usr/local/bin/python3.4
from datetime import datetime
from elasticsearch import Elasticsearch
from elasticsearch_dsl import Search
from elasticsearch_dsl.query import MultiMatch, Match

import smtplib
from email.mime.text import MIMEText
from email.header import Header

host = [0 for i in range(10)]  
i = 1
srcport = "src-port"

es = Elasticsearch(
       ['172.18.220.94'],
       port=9200
     )

#s = Search(using=es,index="logstash-*") \
#    .query('range', ** {'@timestamp': {'gte':'now-1d', 'lt':'now'}})

s = Search(using=es,index="logstash-2017.06.20") \
    .filter('terms', ['src-port', '64690'])
#    .query('range', ** {'@timestamp': {'gte':'now-5m', 'lt':'now'}})

#s.aggs.bucket('Statistics','terms',field='host.keyword',size=10)

#es.get(index="my-index", doc_type="test-type", id=42)['_source']

response = s.execute()

for hit in response:
    print(hit)

#for tag in response.aggregations.Statistics.buckets:
#    host[i] = tag.key
#    i +=1



#Email module
#sender = 'python@rsyslog.localdomain'
#receivers = ['como104@sina.com']

#msg = MIMEText(host[1], 'plain', 'utf-8')
#msg = ['From'] = Header("Jensen", 'utf-8')
#msg = ['To'] = Header("test", 'utf-8')

#subject = 'ELK test mail'
#msg['Subject'] = Header(subject, 'utf-8')

#try:
#   smtpObj = smtplib.SMTP('localhost')
#   smtpObj.sendmail(sender, receivers, msg.as_string())
#   print ("Send mail succesfully")
#except smtplib.SMTPException:
#   print ("Erroro:send mail error")
