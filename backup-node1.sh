#! /bin/bash
date
syst_dir=/backup/
srv_name=alifanov
srv_ip=10.0.2.9
srv_user=backup
srv_dir=data
echo "Start backup ${srv_name}"
mkdir -p ${syst_dir}${srv_name}/increment/
/usr/bin/rsync -avz --progress --delete --password-file=/etc/rsyncd.scrt ${srv_user}@${srv_ip}::${srv_dir}${syst_dir}${srv_name}/current/ --backup --backup-dir=${syst_dir}${srv_name}/increment/`date +%Y-%m-%d`/
/usr/bin/find ${syst_dir}${srv_name}/increment/ -maxdepth 1 -type d-mtime +30 -exec rm -rf {} \;
date
echo "Finish backup ${srv_name}"
