#!/bin/bash

DATE_DAY=`date +%d`
DATE_MONTH=`date +%m`
DATE_YEAR=`date +%Y`
FILEPATH="/var/www/${DATE_YEAR}/${DATE_MONTH}"
FILENAME="${DATE_YEAR}${DATE_MONTH}${DATE_DAY}.txt"

if [ ! -d "${FILEPATH}" ]; then
  mkdir -p ${FILEPATH}; 
done

cat /var/log/mail.log | pflogsumm  > ${FILEPATH}/${FILENAME} || echo "Could not create pflogsummfile. Error." 


