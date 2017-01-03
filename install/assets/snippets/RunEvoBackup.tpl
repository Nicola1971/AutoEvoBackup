/**
 * RunEvoBackup
 *
 * Execute a backup of Evo 
 *
 * @author    Nicola Lambathakis
 * @version    1.2 Beta
 * @category	snippet
 * @internal	@modx_category admin
 * @license 	http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 */

$maxfilesize       = "80M";
$number_of_backups = 6;
$mode              = isset($mode) ? $mode : 'dbonly'; //dbonly,light,medium,full
$rootfiles         = isset($rootfiles) ? $rootfiles : '0'; //1=include root files
$zipdb             = isset($zipdb) ? $zipdb : '0';
$deletesql         = isset($deletesql) ? $deletesql : '1';
$customfiles       = isset($customfiles) ? $customfiles : '0'; //1=include custom files & folders
$customfold1 = isset($customfold1) ? $customfold1 : '';
$customfold2 = isset($customfold2) ? $customfold2 : '';
$customfold3 = isset($customfold3) ? $customfold3 : '';
$customfold4 = isset($customfold4) ? $customfold4 : '';
$customfold5 = isset($customfold5) ? $customfold6 : '';
$modx_root_dir      = $modx->config['base_path'];
$mods_path          = $modx->config['base_path'] . "assets/modules/";
$modx_backup_dir    = $modx->config['base_path'] . '_evobackup_archives/';
$modx_db_backup_dir = $modx->config['base_path'] . 'assets/backup/';
$archive_prefix     = (isset($archive_prefix)) ? $archive_prefix : $modx->config['site_name'];
$archive_suffix     = date('Y-m-d-Hi');
$archive_file       = $modx_backup_dir . $archive_prefix . '_' . $archive_suffix . '_auto_bkp.zip';
$database_filename  = $archive_suffix . '_auto_db_bkp.sql';
    
    if (file_exists($archive_file)) {
    } else {
        /**
         *  Description:
         *  Backup modx files and compress into .zip for easy download
         *  @author Robin Stemp <robinstemp@gmail.com>
         *  @version 0.8 13-Feb-06  Added log tables, excluding log data.
         *                          Added check for .htaccess file, backup directory.
         *                          Added MODx Manager theme header (header.inc.php)
         *                          More testing done.
         *  @version 0.5 11-Feb-2006, not heavily tested though
         *
         *  Setup:
         *     1. change $modx_backup_dir to directory for zip archives and make sure read/write permission is set for directory
         *     2. change $modx_backup_dir in /assets/modules/modbak/download.php file, note download.php requires full path name
         *         ie /home/username/public_html/_backup/
         *
         *  ----------------------------------------
         *  Uses PCLZIP Library for zip compression
         *  Courtesy of http://www.phpconcept.net
         *  ----------------------------------------
         */
        
        /**
         *   Variables to set:
         *       modx_backup_dir [string]
         *                Path to create archives and sql file in, must be writable
         *
         *       archive_prefix  [string]
         *                Prefix for archive filename
         *
         *       archive_suffix  [string]
         *                Suffix for archive filename
         *
         *       database_filename [string]
         *                Filename for SQL dump file
         *
         */
        
        // directory to contain zipped archives, default is servers document root, not secure
        
        
        
        /*
         *  $modx_root_dir
         *        MODx Base path
         *  $mods_path
         *        Modules Path
         */
        
        $dir3 = $modx_root_dir;
        
        $files3 = array();
        $open3  = opendir($dir3);
        while ($file3 = readdir($open3)) {
            if (preg_match("/_evobackup_archives/", $file3) || $file3 == ".." || $file3 == ".") {
            } else {
                $files3[] = $file3;
            }
        }
        closedir($open3);
        rsort($files3);
        $modx_files_array = array(
            $modx_db_backup_dir . $database_filename
        );
        for ($x = 0; $x <= count($files3) - 1; $x++) {
            
            $modx_files_array[] = $modx_root_dir . $files3[$x];
        }
        // Archive file name prefix
        
        
        // Suffix to add to archive name  (ie modxbackup12-11-2005-1735)   .zip will be added to output file
        // include Log table data in database backup, these tables can be quite large, so default is to exclude them
        $dump_log_tables    = false;
        $include_log_tables = false;
        $out                = '';
        // temporary file for archive, this is created and then renamed if zip is successfull
        $tempfile           = $modx_backup_dir . 'tmpbackup.zip';
        if (!defined('PCLZIP_TEMPORARY_DIR')) {
            define('PCLZIP_TEMPORARY_DIR', $modx_backup_dir);
        }
        
        //$archive_file = $modx_backup_dir.$archive_prefix;
        
        $opcode     = isset($_POST['opcode']) ? $_POST['opcode'] : '';
        $dumpdbase  = isset($_POST['dumpdbase']) ? $_POST['dumpdbase'] : '';
        $droptables = isset($_POST['droptables']) ? $_POST['droptables'] : '';
        $filename   = isset($_REQUEST['filename']) ? $_REQUEST['filename'] : '';
        
        $out .= <<<EOD
<script language="JavaScript" type="text/javascript">
function postForm(opcode,filename){
document.module.opcode.value=opcode;
document.module.filename.value=filename;
document.module.submit();
}
</script>
<form name="module" method="post">
<input name="opcode" type="hidden" value="" />
<input name="filename" type="hidden" value="" />
EOD;
        // Backup Manager by Raymond:
        // modified for complete modx backup - 11feb06
        function callBack(&$dumpstring)
        {
            if (!headers_sent()) {
                header('Content-type: application/download');
                header('Content-Disposition: attachment; filename=database_backup.sql');
            }
            echo $dumpstring;
            return true;
        }
        
        function nicesize($size)
        {
            $a = array(
                "B",
                "KB",
                "MB",
                "GB",
                "TB",
                "PB"
            );
            
            $pos = 0;
            while ($size >= 1024) {
                $size /= 1024;
                $pos++;
            }
            if ($size == 0) {
                return "-";
            } else {
                return round($size, 2) . " " . $a[$pos];
            }
        }
        
        /*
         * @package  MySQLdumper
         * @version  1.0
         * @author   Dennis Mozes <opensource@mosix.nl>
         * @url		http://www.mosix.nl/mysqldumper
         * @since    PHP 4.0
         * @copyright Dennis Mozes
         * @license GNU/LGPL License: http://www.gnu.org/copyleft/lgpl.html
         *
         * Modified by Raymond for use with this module
         *
         **/
        class Mysqldumper
        {
            var $_host;
            var $_dbuser;
            var $_dbpassword;
            var $_dbname;
            var $_dbtables;
            var $_isDroptables;
            
            function Mysqldumper($host, $dbuser, $dbpassword, $dbname)
            {
                $this->setHost($host);
                $this->setDBuser($dbuser);
                $this->setDBpassword($dbpassword);
                $this->setDBname($dbname);
                // Don't drop tables by default.
                $this->setDroptables(false);
            }
            
            function setHost($host)
            {
                $this->_host = $host;
            }
            
            function getHost()
            {
                return $this->_host;
            }
            
            function setDBname($dbname)
            {
                $this->_dbname = $dbname;
            }
            
            function getDBname()
            {
                return $this->_dbname;
            }
            
            function getDBuser()
            {
                return $this->_dbuser;
            }
            
            function setDBpassword($dbpassword)
            {
                $this->_dbpassword = $dbpassword;
            }
            
            function getDBpassword()
            {
                return $this->_dbpassword;
            }
            
            function setDBuser($dbuser)
            {
                $this->_dbuser = $dbuser;
            }
            
            function setDBtables($dbtables)
            {
                $this->_dbtables = $dbtables;
            }
            
            // If set to true, it will generate 'DROP TABLE IF EXISTS'-statements for each table.
            function setDroptables($state)
            {
                $this->_isDroptables = $state;
            }
            
            function isDroptables()
            {
                return $this->_isDroptables;
            }
            
            function createDump($dumpLogs = false, $callBack = null)
            {
                
                global $site_name, $full_appname;
                
                // Set line feed
                $lf = "\n";
                
                $resource = mysqli_connect($this->getHost(), $this->getDBuser(), $this->getDBpassword(), $this->getDbname());
                $result   = mysqli_query($resource, "SHOW TABLES");
                $tables   = $this->result2Array(0, $result);
                foreach ($tables as $tblval) {
                    $result               = mysqli_query($resource, "SHOW CREATE TABLE `$tblval`");
                    $createtable[$tblval] = $this->result2Array(1, $result);
                }
                // Set header
                $output = "#" . $lf;
                $output .= "# " . addslashes($site_name) . " Database Dump" . $lf;
                $output .= "# " . $full_appname . $lf;
                $output .= "# " . $lf;
                $output .= "# Host: " . $this->getHost() . $lf;
                $output .= "# Generation Time: " . date("M j, Y at H:i") . $lf;
                $output .= "# Server version: " . mysqli_get_server_info($resource) . $lf;
                $output .= "# PHP Version: " . phpversion() . $lf;
                $output .= "# Database : `" . $this->getDBname() . "`" . $lf;
                $output .= "#";
                
                // Generate dumptext for the tables.
                if (isset($this->_dbtables) && count($this->_dbtables)) {
                    $this->_dbtables = implode(",", $this->_dbtables);
                } else {
                    unset($this->_dbtables);
                }
                foreach ($tables as $tblval) {
                    // check for selected table
                    if (isset($this->_dbtables)) {
                        if (strstr("," . $this->_dbtables . ",", ",$tblval,") === false) {
                            continue;
                        }
                    }
                    $output .= $lf . $lf . "# --------------------------------------------------------" . $lf . $lf;
                    $output .= "#" . $lf . "# Table structure for table `$tblval`" . $lf;
                    $output .= "#" . $lf . $lf;
                    // Generate DROP TABLE statement when client wants it to.
                    if ($this->isDroptables()) {
                        $output .= "DROP TABLE IF EXISTS `$tblval`;" . $lf;
                    }
                    $output .= $createtable[$tblval][0] . ";" . $lf;
                    $output .= $lf;
                    /*
                     *  Insert Data for all tables except log tables(event log, access etc)
                     *  In order to keep sql size down
                     *  @since 13 Feb 06 Robin Stemp <robinstemp@gmail.com>
                     */
                    if ((strpos($tblval, 'slim') === false) && (strpos($tblval, 'log') === false) || $dumpLogs == true) {
                        $output .= "#" . $lf . "# Dumping data for table `$tblval`" . $lf . "#" . $lf;
                        $result = mysqli_query($resource, "SELECT * FROM `$tblval`");
                        $rows   = $this->loadObjectList("", $result);
                        foreach ($rows as $row) {
                            $insertdump = $lf;
                            $insertdump .= "INSERT INTO `$tblval` VALUES (";
                            $arr = $this->object2Array($row);
                            foreach ($arr as $key => $value) {
                                $value = addslashes($value);
                                $value = str_replace("\n", '\\r\\n', $value);
                                $value = str_replace("\r", '', $value);
                                $insertdump .= "'$value',";
                            }
                            $output .= rtrim($insertdump, ',') . ");";
                        }
                    }
                    // invoke callback -- raymond
                    if ($callBack) {
                        if (!$callBack($output))
                            break;
                        $output = "";
                    }
                }
                mysqli_close($resource);
                return ($callBack) ? true : $output;
            }
            
            // Private function object2Array.
            function object2Array($obj)
            {
                $array = null;
                if (is_object($obj)) {
                    $array = array();
                    foreach (get_object_vars($obj) as $key => $value) {
                        if (is_object($value))
                            $array[$key] = $this->object2Array($value);
                        else
                            $array[$key] = $value;
                    }
                }
                return $array;
            }
            
            // Private function loadObjectList.
            function loadObjectList($key = '', $resource)
            {
                $array = array();
                while ($row = mysqli_fetch_object($resource)) {
                    if ($key)
                        $array[$row->$key] = $row;
                    else
                        $array[] = $row;
                }
                mysqli_free_result($resource);
                return $array;
            }
            
            // Private function result2Array.
            function result2Array($numinarray = 0, $resource)
            {
                $array = array();
                while ($row = mysqli_fetch_row($resource)) {
                    $array[] = $row[$numinarray];
                }
                mysqli_free_result($resource);
                return $array;
            }
        }
        @set_time_limit(120); // set timeout limit to 2 minutes
        
        global $dbase, $database_user, $database_password, $dbname, $database_server;
        $dbname = str_replace("`", "", $dbase);
        $dumper = new Mysqldumper($database_server, $database_user, $database_password, $dbname); # Variables have replaced original hard-coded values
        
        $dbcnt     = mysqli_connect($database_server, $database_user, $database_password, $dbname);
        $tableList = mysqli_query($dbcnt, "SHOW TABLES");
        while ($row = mysqli_fetch_row($tableList)) {
            // check if log table
            if ($include_log_tables == false) {
                if (strpos($row[0], 'log') === false) {
                    $tables[] = $row[0];
                }
            } else
                $tables[] = $row[0];
        }
        mysqli_free_result($tableList);
        
        
        // $dumper->setDBtables($tables);
        $dumper->setDroptables(true);
        $dumpfinished = $dumper->createDump($dump_log_tables);
        $fh           = fopen($modx_db_backup_dir . $database_filename, 'w');
        
        if ($dumpfinished) {
            fwrite($fh, $dumpfinished);
            fclose($fh);
            chmod($modx_db_backup_dir . $database_filename, 0600);
            
            // modes
            if ($mode !== 'dbonly') {
                /**
                 * Zip directories into archive
                 */
                set_time_limit(250);
                ini_set("memory_limit", $maxfilesize);
                
                
                
                include $modx->config['base_path'] . "assets/modules/evobackup/pclzip.lib.php";
                //added*/
                global $modx;
                $MGR_DIR = MGR_DIR;
                if ($mode = 'light') {
                    $modx_files_array   = array(
                        $modx_root_dir . 'assets/index.html'
                    );
                    $modx_files_array[] = $modx_root_dir . 'assets/templates';
                    $modx_files_array[] = $modx_root_dir . 'assets/files';
                    $modx_files_array[] = $modx_root_dir . 'assets/flash';
                    $modx_files_array[] = $modx_root_dir . 'assets/images';
                    $modx_files_array[] = $modx_root_dir . 'assets/media';
                    $modx_files_array[] = $modx_root_dir . $MGR_DIR . '/includes/config.inc.php';
                } 
				else if ($mode = 'medium') {
                    $modx_files_array   = array(
                        $modx_root_dir . 'assets/index.html'
                    );
                    $modx_files_array[] = $modx_root_dir . 'assets/templates';
                    $modx_files_array[] = $modx_root_dir . 'assets/files';
                    $modx_files_array[] = $modx_root_dir . 'assets/flash';
                    $modx_files_array[] = $modx_root_dir . 'assets/images';
                    $modx_files_array[] = $modx_root_dir . 'assets/media';
                    $modx_files_array[] = $modx_root_dir . 'assets/modules';
                    $modx_files_array[] = $modx_root_dir . 'assets/plugins';
                    $modx_files_array[] = $modx_root_dir . 'assets/site';
                    $modx_files_array[] = $modx_root_dir . 'assets/snippets';
                    $modx_files_array[] = $modx_root_dir . 'assets/tvs';
                    $modx_files_array[] = $modx_root_dir . 'assets/lib';
                    $modx_files_array[] = $modx_root_dir . 'assets/js';
                    $modx_files_array[] = $modx_root_dir . $MGR_DIR . '/includes/config.inc.php';
                } 
				else if ($mode = 'full') {
                    $modx_files_array   = array(
                        $modx_root_dir . 'assets'
                    );
                    $modx_files_array[] = $modx_root_dir . 'manager';
                }
                if ($rootfiles != '0') {
                    $modx_files_array[] = $modx_root_dir . 'index.php';
                    if (file_exists($modx_root_dir . 'index-ajax.php')) {
                        $modx_files_array[] = $modx_root_dir . 'index-ajax.php';
                    }
                    if (file_exists($modx_root_dir . '.htaccess')) {
                        $modx_files_array[] = $modx_root_dir . '.htaccess';
                    }
                    if (file_exists($modx_root_dir . 'robots.txt')) {
                        $modx_files_array[] = $modx_root_dir . 'robots.txt';
                    }
                }
				if ($customfiles != '0') {
				//custom files and folders
				if ($customfold1!='' && file_exists($modx_root_dir.$customfold1))
				{
    			$modx_files_array[]=$modx_root_dir.$customfold1;
				}  
				if ($customfold2!='' && file_exists($modx_root_dir.$customfold2))
				{
    			$modx_files_array[]=$modx_root_dir.$customfold2;
				} 
				if ($customfold3!='' && file_exists($modx_root_dir.$customfold3))
				{
    			$modx_files_array[]=$modx_root_dir.$customfold3;
				}
				if ($customfold4!='' && file_exists($modx_root_dir.$customfold4))
				{
    			$modx_files_array[]=$modx_root_dir.$customfold4;
				}
				if ($customfold5!='' && file_exists($modx_root_dir.$customfold5))
				{
    			$modx_files_array[]=$modx_root_dir.$customfold5;
				}
				}
                //add files to zip
                $archive = new PclZip($tempfile);
                $v_list  = $archive->create($modx_files_array, PCLZIP_OPT_REMOVE_PATH, $modx_root_dir);
                if ($v_list == 0) {
                    $out .= "Error : " . $archive->errorInfo(true);
                    return $out;
                }
                //add db to zip
                if ($zipdb != '0') {
                    $archive = new PclZip($tempfile);
                    $v_list  = $archive->add($modx_db_backup_dir . $database_filename, PCLZIP_OPT_REMOVE_PATH, $modx_db_backup_dir);
                    if ($v_list == 0) {
                        $out .= "Error : " . $archive->errorInfo(true);
                        return $out;
                    }
                }
                rename($tempfile, $archive_file);
				chmod($archive_file, 0600);
                if ($zipdb != '0') {
                    // rename
                    $fileBits = explode('.', $archive_file);
                    $ext      = array_pop($fileBits);
                    $fname    = implode('.', $fileBits);
                    $filename = str_replace(' ', '_', $fname);
                    rename($archive_file, $filename . '_db.' . $ext);
                    //delete sql
                    if ($deletesql != '0') {
                        unlink($modx_db_backup_dir . $database_filename);
                    }
                }
			}//end mode !=dbonly  
            
			$dir2   = $modx_backup_dir;
            $files2 = array();
            $open2  = opendir($dir2);
            while ($file2 = readdir($open2)) {
                if (preg_match("/_auto_bkp/", $file2))
                    $files2[] = $file2;
            }
            closedir($open2);
            rsort($files2);
			
            // sql database filename
            
            if (array_key_exists($number_of_backups, $files2)) {
                unlink($modx_backup_dir . $files2[$number_of_backups]);
            }
            
        } else {
            $o->setError(1, "Unable to Backup Database");
            $o->dumpError();
        }
    }