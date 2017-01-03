# AutoEvoBackup

**Automatic EvoBackup on system events**

https://www.youtube.com/watch?v=VQMrsLxolHE

Based on **EvoBackup** Module https://github.com/Nicola1971/EvoBackup

and 

**AutoBackupIncremental** by xyzvisual https://modx.com/extras/package/autobackupincremental 

AutoEvoBackup generates db only or db+files backup of a modx evotion website, on any modx system event.
For example, you can make backup before or after document save, before logout from manager, or after the login...

This plugin works standalone, but is suggested to use with **EvoBackup Module**, as backup manager to view download or delete backup .zip archives.
https://github.com/Nicola1971/EvoBackup


# Backup Modes:

* Choosing dbonly, backups are saved into default Evo db backup directory (assets/backup)
* Choosing db+files (light,medium,full) files backups are saved into EvoBackup folder (root/_evobackup_archives) and you can choose to include (copy or move) the .sql file to zip.

# Manager Roles Options:

You can set wich manager user Run the Backup when fires the System Event. 

### Available options:
* All // run backup for All
* AdminOnly // run backup only for Admin role 1
* AdminExcluded // run backup for all manager users excluded Admin role 1
* ThisRoleOnly // run backup only for "this" role id
* ThisUserOnly // run backup only for "this" username

Install:
- Install with package Manager
- create a folder in root: /_evobackup_archives




