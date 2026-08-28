#Setup Notes
Step 1 — Build the Virtual Machine

I created the Ubuntu Server VM called sandbox01 for the internship work.

The VM was set up with 2 vCPUs, 2048 MB RAM, and a 20 GB dynamically allocated disk. I installed Ubuntu Server 24.04 LTS and enabled OpenSSH Server during installation.

After logging into the VM, I updated the system:

sudo apt update
sudo apt upgrade


I also created a VirtualBox snapshot called clean-install so I could restore the VM to the clean state if I made a serious mistake.

Step 2 — Create the Users and Group

I created the admin user. I had an earlier attempt where I deleted the account and then created it again, so I checked the account after recreating it:

sudo adduser admin
sudo userdel admin
id admin
sudo adduser admin
id admin


I then created the other two required users:

sudo adduser dev
sudo adduser intern


I checked that the users existed:

id dev
id intern


I created the devs group:

sudo addgroup devs


I added dev and intern to the group:

sudo usermod -a -G devs dev
sudo usermod -a -G devs intern


I checked the group membership:

id dev
getent group devs


I used -a with usermod -G because without -a, the user's existing supplementary groups would be replaced.

Step 3 — Create the Shared Directory and Set Permissions

I created the shared directory:

sudo mkdir -p /opt/project_files


I changed the owner and group:

sudo chown admin:devs /opt/project_files


Then I set the directory permissions to 750:

sudo chmod 750 /opt/project_files


I checked the directory:

ls -ld /opt/project_files


There were a few path typos while checking the directory, such as using /opt/project_fils instead of /opt/project_files. I corrected the path and continued with the correct directory.

I tested access using the different accounts:

sudo -u admin touch /opt/project_files/from-admin.txt
sudo -u dev touch /opt/project_files/from-dev.txt
sudo -u intern touch /opt/project_files/from-intern.txt
sudo -u intern cat /opt/project_files/from-dev.txt


I also repeated some of the read tests while troubleshooting the permissions:

sudo -u intern cat /opt/project_files/from-admin.txt
sudo -u intern cat /opt/project_files/from-dev.txt


These tests were used to confirm that the permissions were actually working instead of assuming they were correct. The final results are documented in permissions-test.md.

Step 4 — Make Permissions Work for New Files

I created a new file as dev:

sudo -u dev touch /opt/project_files/newfile.txt


Then I checked its permissions:

ls -l /opt/project_files/newfile.txt
sudo ls -l /opt/project_files/newfile.txt


This showed the problem with newly created files. A new file does not simply inherit all the permissions of the directory. Its group and permission bits are affected by the creating user's account and umask. This can cause a file created by one team member to be inaccessible to another team member.

I checked access to the existing file while troubleshooting:

sudo -u intern cat /opt/project_files/from-dev.txt
sudo -u dev cat /opt/project_files/from-dev.txt


I applied an ACL to the shared directory:

sudo setfacl -m u:dev:rwx /opt/project_files


I tested the file access again:

sudo -u dev touch /opt/project_files/from-dev.txt
sudo -u intern cat /opt/project_files/from-dev.txt


I then enabled the setgid bit on the directory:

sudo chmod g+s /opt/project_files
ls -ld /opt/project_files


The setgid bit makes newly created files and directories inherit the devs group from /opt/project_files.

I checked the group ownership of the file:

stat -c '%G' /opt/project_files/from-dev.txt
sudo stat -c '%G' /opt/project_files/from-dev.txt


I recreated the file to test group inheritance:

sudo -u admin rm /opt/project_files/from-dev.txt
sudo -u admin ls /opt/project_files/
sudo -u dev touch /opt/project_files/from-dev.txt
sudo stat -c '%G' /opt/project_files/from-dev.txt


Finally, I checked the ACL configuration:

getfacl /opt/project_files


The final output showed:

# file: opt/project_files
# owner: admin
# group: devs
# flags: -s-
user::rwx
user:dev:rwx
group::r-x
mask::rwx
other::---
default:user::rwx
default:user:dev:rwx
default:group::r-x
default:mask::rwx
default:other::---


The default: entries confirmed that default ACLs were present on the directory.

After the permissions were fixed, a new file created by dev could be read by intern without manually changing the file with chmod.

The main fix was using the directory's setgid bit together with the ACL configuration so that group ownership and permissions continued to work for new files.

Step 5 — Create and Test the Backup Script

I created the backup script at /opt/scripts/backup.sh:

sudo nano /opt/scripts/backup.sh


The script contains:

#!/bin/bash

mkdir -p /opt/backups
DATE=$(date +%Y-%m-%d)
tar -czf /opt/backups/project_files-$DATE.tar.gz /opt/project_files
du -h /opt/backups/project_files-$DATE.tar.gz


The script creates /opt/backups, creates a compressed archive of /opt/project_files using the current date in the filename, and displays the size of the resulting archive.

I also checked the script:

sudo cat /opt/scripts/backup.sh


The backup directory was checked:

sudo ls -lh /opt/backups/


The directory contained:

project_files-2026-08-27.tar.gz
project_files-2026-08-28.tar.gz


I checked the contents of the latest backup:

sudo tar -tzf /opt/backups/project_files-2026-08-28.tar.gz


The archive contained:

opt/project_files/
opt/project_files/from-admin.txt
opt/project_files/newfile.txt
opt/project_files/from-dev.txt


I first tried to check /tmp/backup-test, but the directory did not exist yet:

sudo find /tmp/backup-test -type f -print


This returned an error because the directory had not been created.

I then created the directory:

sudo mkdir -p /tmp/backup-test


I extracted the backup:

sudo tar -xzf /opt/backups/project_files-2026-08-28.tar.gz -C /tmp/backup-test


Finally, I checked the extracted files:

sudo find /tmp/backup-test -type f -print


The files were successfully extracted:

/tmp/backup-test/opt/project_files/from-dev.txt
/tmp/backup-test/opt/project_files/newfile.txt
/tmp/backup-test/opt/project_files/from-admin.txt


This confirmed that the backup was a real, usable archive and could be restored successfully.

Step 6 — Schedule the Backup

The backup job was configured in the root user's crontab.

I first checked/exported the root crontab:

sudo crontab -l > ~/crontab.txt


Then I checked the saved file:

cat crontab.txt


I originally used:

crontab -l > ~/crontab.txt


but that checked the current user's crontab. Since the backup cron job was configured for root, I corrected this by using:

sudo crontab -l > ~/crontab.txt


The cron job uses the absolute path to the backup script because cron runs with a minimal environment and does not use the same working directory as an interactive shell.

The cron job sends both normal output and errors to:

/var/log/backup.log


The 2>&1 part sends standard error (stderr) to the same destination as standard output (stdout).

Final Checks

I checked the users:

id admin
id dev
id intern


I checked the devs group:

getent group devs


I checked the shared directory:

ls -ld /opt/project_files


I checked the ACL configuration:

getfacl /opt/project_files


I also verified the backup by listing the archive contents with tar -tzf and extracting it successfully into /tmp/backup-test.
