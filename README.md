# AutoEvoBackup

**Automatic EvoBackup on system events**

https://www.youtube.com/watch?v=VQMrsLxolHE

Based on **EvoBackup** Module https://github.com/Nicola1971/EvoBackup

and 

**AutoBackupIncremental** by xyzvisual https://modx.com/extras/package/autobackupincremental 

AutoEvoBackup generates db only or db+files backup of a modx evotion website, on any modx system event.
For example, you can make backup before or after document save, before logout from nanager, or after the login...

This plugin works standalone, but suggested to use with EvoBackup Module (as backup manager)
Evo files and compress into .zip for easy download

* Choosing dbonly, backups are saved into default Evo db backup directory (assets/backup)
* Choosing db+files (light,medium,full) backups are saved into EvoBackup folder (root/_evobackup_archives)

