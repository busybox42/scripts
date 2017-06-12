#!/bin/bash

LMTP=`zcat /var/log/archive/haraka.log.1.gz |grep -a '\[NOTICE\]'|grep "mode=LMTP"|wc -l`
SMTP=`zcat /var/log/archive/haraka.log.1.gz |grep -a '\[NOTICE\]'|grep "mode=SMTP"|wc -l`
REJ=`zcat /var/log/archive/haraka.log.1.gz |grep -a '\[core\]'|grep "S: 5"|wc -l`
DEF=`zcat /var/log/archive/haraka.log.1.gz |grep -a '\[core\]'|grep "S: 4"|wc -l`
VOLUME=`zcat /var/log/archive/haraka.log.1.gz |grep -a '\[core\]'|grep " size=" |awk '{print $7}'|sed 's/size=//'| paste -sd+ | bc`

echo " ---------------"
echo "| Top 10 Report |"
echo " ---------------"
echo ""
echo " -= Senders =-"
zcat /var/log/archive/haraka.log.1.gz |grep -a '\[core\]'|grep "MAIL FROM:" |grep "PROTOCOL"|awk '{print $7}'|sed 's/FROM://' |sort |uniq -c |sort -nr|head -n10
echo ""
echo " -= Recievers =-"
zcat /var/log/archive/haraka.log.1.gz |grep -a '\[core\]'|grep "RCPT TO:" |grep "PROTOCOL"|awk '{print $7}'|sed 's/TO://' |sed 's/\\r$//'|sort |uniq -c |sort -nr|head -n10
echo ""
echo " -= Connecting IP's =-"
zcat /var/log/archive/haraka.log.1.gz |grep -a " connect ip=" |awk '{print $6}'|sed 's/ip=//'|sort |uniq -c |sort -nr |head -n10
echo ""
echo " -= 5xx Rejections =-"
zgrep -a "] S: 5" /var/log/archive/haraka.log.1.gz|awk -F "] S:" '{print $2}' |sed 's/\[.*\]/\[\]/' |sed 's/see\ http.*//'|sort |uniq -c |sort -nr |head -n10
echo ""
echo " -= 4xx Deferrals =-"
zgrep -a "] S: 4" /var/log/archive/haraka.log.1.gz|awk -F "] S:" '{print $2}' |sed 's/\[.*\]/\[\]/' |sed 's/see\ http.*//'|sort |uniq -c |sort -nr |head -n10
echo ""
echo " -----------------------------------------------------"
echo ""
echo " --------"
echo "| Totals |"
echo " --------"
echo ""
echo " LMTP Deliveries: ${LMTP}"
echo " SMTP Deliveries: ${SMTP}"
echo " 5xx Rejections:  ${REJ}"
echo " 4xx Defferals:   ${DEF}"
echo " Email Volume:    ${VOLUME} Bytes" 
