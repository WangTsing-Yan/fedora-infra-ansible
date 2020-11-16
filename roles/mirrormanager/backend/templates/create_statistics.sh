#!/bin/sh

MIRRORLIST_PROXIES="{% for host in groups['mirrorlist_proxies'] %} {{ host }} {% endfor %}"
FRONTENDS="{% for host in groups['mm_frontend'] %} {{ host }} {% endfor %}"

INPUT="/var/log/mirrormanager/mirrorlist.log"
CONTAINER1="/var/log/mirrormanager/mirrorlist1.service.log"
CONTAINER2="/var/log/mirrormanager/mirrorlist2.service.log"

if [ "$1" == "yesterday" ]; then
	STATISTICS="/usr/bin/mirrorlist_statistics -o 1"
	DEST="/var/www/mirrormanager-statistics/data/`date +%Y/%m --date='yesterday'`"
else
	STATISTICS="/usr/bin/mirrorlist_statistics"
	DEST="/var/www/mirrormanager-statistics/data/`date +%Y/%m`"
fi

DATE=`date +%Y%m%d`
OUTPUT=`mktemp -d`

trap "rm -f ${OUTPUT}/*; rmdir ${OUTPUT}" QUIT TERM INT HUP EXIT

for s in ${MIRRORLIST_PROXIES}; do
	ssh $s "( cat $CONTAINER1 | grep -v 127.0.0.1 | gzip -4 )" >> ${OUTPUT}/mirrorlist.log.gz
	ssh $s "( cat $CONTAINER2 | grep -v 127.0.0.1 | gzip -4 )" >> ${OUTPUT}/mirrorlist.log.gz
	if [ "$1" == "yesterday" ]; then
		ssh $s "( xzcat $CONTAINER1-${DATE}.xz | grep -v 127.0.0.1 | gzip -4 )" >> ${OUTPUT}/mirrorlist.log.gz
		ssh $s "( xzcat $CONTAINER2-${DATE}.xz | grep -v 127.0.0.1 | gzip -4 )" >> ${OUTPUT}/mirrorlist.log.gz
	fi
done

${STATISTICS} -l ${OUTPUT}/mirrorlist.log.gz -d ${OUTPUT}/

for f in ${FRONTENDS}; do
	ssh ${f} mkdir -p ${DEST}
	rsync -aq ${OUTPUT}/{*.png,*.txt} ${f}:${DEST}
done
