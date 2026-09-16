#Permissions Test

Step 3 — Initial Permission Tests

I first created /opt/project_files and set admin as the owner, devs as the group, with 750 permissions.

The directory was configured with:

sudo chown admin:devs /opt/project_files
sudo chmod 750 /opt/project_files


I then tested access using the different accounts.

Test 1 — admin creates a file
sudo -u admin touch /opt/project_files/from-admin.txt


Result: Succeeded.

admin is the owner of the directory and has rwx permissions.

Test 2 — dev creates a file
sudo -u dev touch /opt/project_files/from-dev.txt


Result: Refused.

At this point, dev was a member of the devs group, but the group had only r-x permissions on the directory. The group did not have write permission, so dev could not create a file.

This was an important finding because being a member of a group does not automatically mean that the group has write access.

Test 3 — intern creates a file
sudo -u intern touch /opt/project_files/from-intern.txt


Result: Refused.

intern was also a member of devs, but the group did not have write permission. This meant intern could read and enter the directory but could not create files.

Test 4 — intern reads dev's file
sudo -u intern cat /opt/project_files/from-dev.txt


The read test was performed during the permission troubleshooting. The purpose was to check whether intern could read a file created by dev.

Step 4 — Fixing the New File Permissions

The first problem was that dev could not create a file because the devs group did not have write permission.

I gave the specific user dev rwx access using an ACL:

sudo setfacl -m u:dev:rwx /opt/project_files


I then repeated the file creation test:

sudo -u dev touch /opt/project_files/from-dev.txt


Result: Succeeded.

The ACL gave dev the required write permission even though the normal devs group permissions were still r-x.

However, I noticed another problem. The newly created file was not using devs as its group. The file was owned by dev, but its group was not inherited from the shared directory.

I checked the group with:

stat -c '%G' /opt/project_files/from-dev.txt


This showed that giving dev access with an ACL solved the write problem, but it did not solve group inheritance.

Using setgid

To make new files inherit the directory's group, I enabled the setgid bit:

sudo chmod g+s /opt/project_files


I checked the directory:

ls -ld /opt/project_files


The s in the group permission position confirmed that the setgid bit was enabled.

I then recreated the file and checked its group:

sudo -u admin rm /opt/project_files/from-dev.txt
sudo -u dev touch /opt/project_files/from-dev.txt
sudo stat -c '%G' /opt/project_files/from-dev.txt


Result:

The file was still owned by dev, but its group was now devs.

This was the important difference:

Owner: dev
Group: devs

The file itself does not become a "member" of the group. Instead, its group ownership is set to devs, which allows the group permissions and ACL rules to apply.

Final access test

After the permissions were fixed, I tested the file again:

sudo -u dev touch /opt/project_files/newfile.txt
sudo -u intern cat /opt/project_files/newfile.txt


Result:

dev was able to create the file.
intern was able to read the file.
No manual chmod was needed between the two tests.

I also checked the final ACL configuration:

getfacl /opt/project_files


The output showed default ACL entries:

default:user::rwx
default:user:dev:rwx
default:group::r-x
default:mask::rwx
default:other::---


This confirmed that default ACL entries were present on the directory.

Conclusion

The first problem was that the devs group had r-x permissions and therefore dev could not create files.

The first fix was an ACL giving the specific user dev rwx access:

sudo setfacl -m u:dev:rwx /opt/project_files


This allowed dev to create files, but the new files did not inherit the devs group.

The second fix was enabling the setgid bit:

sudo chmod g+s /opt/project_files


After this, files created by dev remained owned by dev but inherited devs as their group. This allowed the shared group permissions and ACL configuration to work correctly for new files.

Finally, intern was able to read a file created by dev without manually changing its permissions.
