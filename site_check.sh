#!/bin/bash 
# function:monitor tcp connect status from zabbix 
  
source /etc/bashrc >/dev/null 2>&1 
source /etc/profile  >/dev/null 2>&1 
#/usr/bin/curl -o /dev/null -s -w %{http_code} http://$1/ 
  
web_site_discovery () { 
WEB_SITE=($(cat  /etc/zabbix/host_list|grep -v "^#")) 
        printf '{\n' 
        printf '\t"data":[\n' 
for((i=0;i<${#WEB_SITE[@]};++i)) 
{ 
num=$(echo $((${#WEB_SITE[@]}-1))) 
        if [ "$i" != ${num} ]; 
                then 
        printf "\t\t{ \n" 
        printf "\t\t\t\"{#SITENAME}\":\"${WEB_SITE[$i]}\"},\n" 
                else 
                        printf  "\t\t{ \n" 
                        printf  "\t\t\t\"{#SITENAME}\":\"${WEB_SITE[$num]}\"}]}\n" 
        fi 
} 
} 
  
web_site_code () { 
/usr/bin/curl -o /dev/null -s -w %{http_code} https://$1 
} 

web_site_ssl () {
TS=`echo| openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -dates|tail -1|cut -f 2 -d=`
NOW=`date`
DIFF=$(expr `date -d "${TS}" +"%s"` - `date -d "${NOW}" +"%s"`)
expr ${DIFF} / 86400
}
  
case "$1" in 
web_site_discovery) 
web_site_discovery 
;;
web_site_code) 
web_site_code $2 
;; 
web_site_ssl) 
web_site_ssl $2 
;; 
*) 
  
echo "Usage:$0 {web_site_discovery|web_site_code|web_site_ssl [URL]}" 
;; 
esac
