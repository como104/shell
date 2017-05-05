#!/bin/bash
#Samba backup shell version 1.1 create on 2016/4/6 by Jensen.

#Global variable

##Samba server login account & password.##
USER=
PASSWORD=

##Destination path & Source path.##
DISTPATH=
SRCPATH=

#Example.Input HR and SZ file path.
HRFILE=
SZFILE=

##Email address.Send the informations of logs to your Email.
EMAIL=

function FullBackup() {
#HR and SZ documents full backup example.
  tar -zcPf "$BACKUPDISTPATH/`date +%F`hrfullbackup.tar.gz" $HRFILE --exclude /HR/scan --exclude /HR/photo_video && echo "HR data backup successfully!" >> samba_backup_log || echo "HR data backup fail!" >> samba_backup_log
  
  tar -zcPf "$BACKUPDISTPATH/`date +%F`szfullbackup.tar.gz" $SZFILE && echo "SZ databackup successfully!" >> samba_backup_log || echo "SZ data backup fail!" >> samba_backup_log

  echo >> samba_backup_log
  cp -R $BACKUPDISTPATH $SRCPATH && echo "Backup copy complete!" >> samba_backup_log

  date +%F > /home/samba/backup/backupfull-backup-data
}

function DailyBackup() {
  if [ -f /home/samba/backup/backupfull-backup-data ]
  then
    tar -N $(cat /home/samba/backup/backupfull-backup-data) -zcPf "$BACKUPDISTPATH/`date +%F`hrfullbackup.tar.gz" $HRFILE --exclude /HR/scan --exclude /HR/photo_video && echo "HR data backup successfully!" >> samba_backup_log || echo "HR data backup fail!" >> samba_backup_log
  
    tar -N $(cat /home/samba/backup/backupfull-backup-data) -zcPf "$BACKUPDISTPATH/`date +%F`szfullbackup.tar.gz" $SZFILE && echo "SZ databackup successfully!" >> samba_backup_log || echo "SZ data backup fail!" >> samba_backup_log

    echo >> samba_backup_log
    cp -R $BACKUPDISTPATH $SRCPATH && echo "Backup copy complete!" >> samba_backup_log
  else
    echo "Error,the backupfull-backup-data file is not exist!Please check!" >> samba_backup_log
  fi
}

#kill all connecting users
CONNECT=$(netstat -atpln | grep 445 | grep ESTABLISHED | awk '{print $7}' | cut -d / -f 1)

for usr in $CONNECT
do
    if [ $usr != "-" ]
    then
      kill -9 $usr
    else
      echo >> /dev/null
    fi
done

cd /home/samba/backup
mkdir `date +%F`
chmod 755 `date +%F`
cd `date +%F`
BACKUPDISTPATH=/home/samba/backup/`date +%F`   

#create log file
touch samba_backup_log
chmod 666 samba_backup_log
echo "`date +%F` Samba remote backup report" >> samba_backup_log
echo "*************************************" >> samba_backup_log
echo

#Mount remote path
mount -t cifs -o username="$USER",password="$PASSWORD" $DISTPATH $SRCPATH

if [ "`date +%a`" = "Sun" ]
then
  FullBackup 
  old_day=`date +%F -d"-7 days"`
  echo >> samba_backup_log
  rm -rf $SRCPATH/$old_day && echo "Old backup file remove successful,backup finish!" >> samba_backup_log || echo "No old backup files.Backup finish!" >> samba_backup_log

else
  DailyBackup
  old_day=`date +%F -d"-7 days"`
  echo >> samba_backup_log
  rm -rf $SRCPATH/$old_day && echo "Old backup file remove successful,backup finish!" >> samba_backup_log || echo "No old backup files.Backup finish!" >> samba_backup_log
fi

umount $SRCPATH && echo "Unmount network drive." >> samba_backup_log

#Send the backup logs to Email
mail -s "Samba remote data backup report" $EMAIL < samba_backup_log
rm -f samba_backup_log

cd /home/samba/backup
rm -rf `date +%F`
