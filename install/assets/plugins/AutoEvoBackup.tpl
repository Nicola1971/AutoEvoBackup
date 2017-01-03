//<?php
/**
 * AutoEvoBackup
 *
 * Automatic EvoBackup on system events
 *
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    1.2 Beta
 * @license	 http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnBeforeManagerLogout,OnManagerLogin,OnBeforeDocFormSave
 * @internal    @disabled  1
 * @internal    @installset base
 * @internal    @modx_category Admin
 * @internal @properties  &mode= mode:;list;dbonly,light,medium,full;dbonly;;Choose a Backup type &rootfiles= rootfiles:;list;0,1;0;;add index, index-ajax, robots and htaccess to the backup  &zipdb= zip .sql:;list;0,1;0;include .sql db backup to the zip &deletesql= delete sql:;list;0,1;0;after zip, delete sql file from backup folder &customfiles= enable custom files:;list;0,1;0;;add custom files and folders to the backup &customfold1=Custom file or folder 1:;string;; &customfold2=Custom file or folder 2:;string;; &customfold3=Custom file or folder 3:;string;; &customfold4=Custom file or folder 4:;string;; &customfold5=Custom file or folder 5:;string;; 
 */

$mode = isset($mode) ? $mode : 'light';//dbonly,light,medium,full
$rootfiles = isset($rootfiles) ? $rootfiles : '0';//1=include root files
$zipdb = isset($zipdb) ? $zipdb : '0';
$deletesql = isset($deletesql) ? $deletesql : '1';
$customfiles = isset($customfiles) ? $customfiles : '0'; //1=include custom files & folders
$customfold1 = isset($customfold1) ? $customfold1 : '';
$customfold2 = isset($customfold2) ? $customfold2 : '';
$customfold3 = isset($customfold3) ? $customfold3 : '';
$customfold4 = isset($customfold4) ? $customfold4 : '';
$customfold5 = isset($customfold5) ? $customfold6 : '';
//events
$e = &$modx->Event;
// Ditto parameters
$params['mode'] = $mode;
$params['rootfiles'] = $rootfiles;
$params['zipdb'] = $zipdb;
// run backup
$backup = $modx->runSnippet('RunEvoBackup', $params);
$output = $backup;
$e->output($output);
return;
?>