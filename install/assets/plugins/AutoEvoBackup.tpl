//<?php
/**
 * AutoEvoBackup
 *
 * Automatic EvoBackup on system events
 *
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    1.3
 * @license	 http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnBeforeManagerLogout
 * @internal    @disabled  1
 * @internal    @installset base
 * @internal    @modx_category Admin
 * @internal @properties &allow_backup=Run Backup for:;list;All,AdminOnly,AdminExcluded,ThisRoleOnly,ThisUserOnly;All &ThisRole=Run only for this role:;string;;;(role id) &ThisUser=Run only for this user:;string;;;(username) &bkpmode= mode:;list;dbonly,light,medium,full;dbonly;;Choose a Backup type &rootfiles= rootfiles:;list;0,1;0;;add index index-ajax robots and htaccess to the backup  &zipdb= zip .sql:;list;0,1;0;;include .sql db backup to the zip &deletesql= delete sql:;list;0,1;0;;after zip delete sql file from backup folder &customfiles= enable custom files:;list;0,1;0;;add custom files and folders to the backup &customfold1=Custom file or folder 1:;string;; &customfold2=Custom file or folder 2:;string;; &customfold3=Custom file or folder 3:;string;; &customfold4=Custom file or folder 4:;string;; &customfold5=Custom file or folder 5:;string;; &number_of_backups= Number of backups:;string;6;;number of incremental backups before overwrite  &sendEmail=Send download backup link:;menu;yes,no;no &SendTo=Send to email address:;string;;;enter email &SendToCC=Send to CC email address:;string;;;enter email &emSubject=Subject:;string;Auto Backup Done;;ie: Auto Backup Done 
 */
if(!defined('MODX_BASE_PATH')){die('What are you doing? Get out of here!');}
//events
$backup = '';
$e = &$modx->Event;
// RunEvoBackup parameters
$params['mode'] = $bkpmode;
$params['rootfiles'] = $rootfiles;
$params['zipdb'] = $zipdb;
$params['deletesql'] = $deletesql;
$params['customfiles'] = $customfiles;
$params['number_of_backups'] = $number_of_backups;
$params['sendEmail'] = $sendEmail;
$params['SendTo'] = $SendTo;
$params['subject'] = $subject;
$params['SendToCC'] = $SendToCC;
// get manager role
$internalKey = $modx->getLoginUserID();
$sid = $modx->sid;
$role = $_SESSION['mgrRole'];
$user = $_SESSION['mgrShortname'];

// run backup for All
if($allow_backup == 'All') {
$backup = $modx->runSnippet('RunEvoAutoBackup', $params);
}
else 
// run backup only for Admin role 1
if(($role==1) AND ($allow_backup == 'AdminOnly')) {
$backup = $modx->runSnippet('RunEvoAutoBackup', $params);
}
else
// run backup for all manager users excluded Admin role 1
if(($role!==1) AND ($allow_backup == 'AdminExcluded')) {
$backup = $modx->runSnippet('RunEvoAutoBackup', $params);
}
else
// run backup only for "this" role id
if(($role==$ThisRole) AND ($allow_backup == 'ThisRoleOnly')) {
$backup = $modx->runSnippet('RunEvoAutoBackup', $params);
}
else
if(($user==$ThisUser) AND ($allow_backup == 'ThisUserOnly')) {
$backup = $modx->runSnippet('RunEvoAutoBackup', $params);
}
else {
$backup = '';
}
$e->output($backup);
return;
?>