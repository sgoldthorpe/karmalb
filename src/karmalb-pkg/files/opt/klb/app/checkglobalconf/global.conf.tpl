#!!!!!!NO REMOVE COMMENTS LINES!!!!!!
#!!!!!!comments lines have a special patron that web application have to process 

#::INI Global information
#Document Root for Web Aplication  directory
$basedir="/opt/klb/www";#update
#configuration directory.In this section all config files are saved.
$configdir="/opt/klb/config";#update
#Log directory
$logdir="/opt/klb/logs/";#update
#log filename for this Graphic user interface.Some action with this GUI will be saved here.
$logfile="/opt/klb/logs/zenloadbalancer.log";#update
#.<b>Time out execution KLB GUI CGIs.</b> <font size=1>When timeout is exceded the cgi execution is killed automatically.</font>
$timeouterrors="60";
#File configuration Zen Cluster
$filecluster="/opt/klb/config/cluster.conf";#update
#File configuration GUI
$confhttp="/opt/klb/app/mini_httpd/mini_httpd.conf";#update
$ntp="pool.ntp.org"; #delete
#chrony server file extract
$filetimeserv="/opt/klb/config/timeservers.conf";
#Do backup to
$backupfor="$configdir $confhttp /etc/iproute2/rt_tables /etc/sysctl.d/70-karmalb.conf";
#Save backups on
$backupdir="/opt/klb/backups/";#update
#rt tables file
$rttables = "/etc/iproute2/rt_tables";
#this file
$globalcfg = "/opt/klb/config/global.conf";#update
#version KLB
$version="1.0a3";#update
#Cipher PCI
$cipher_pci="DEFAULT";#update

#dns file server?
$filedns="/etc/resolv.conf";
#apt file
$fileapt="/etc/apt/sources.list";
#Where is tar binary?
$tar="/bin/tar";
#where is ifconfig binary?
$ifconfig_bin="/sbin/ifconfig";
#Where is ip binary?
$ip_bin="/sbin/ip";
$pen_bin="/opt/klb/app/pen/bin/pen";#delete
$pen_ctl="/opt/klb/app/pen/bin/penctl";#delete
#Where is fdisk binary?
$fdisk_bin="/sbin/fdisk";
#Where is df binary?
$df_bin="/bin/df";
#Where is ssh-keygen binary?
$sshkeygen="/usr/bin/ssh-keygen";
#Where is ssh client?
$ssh="/usr/bin/ssh";
#Where is scp binary?
$scp="/usr/bin/scp";
#Where is rsync binary?
$rsync="/usr/bin/rsync";
#Where is ucarp binary?
$ucarp="/usr/sbin/ucarp";
#Where is pidof binary?
$pidof="/bin/pidof";
#Where is ps binary?
$ps="/bin/ps";
#Where is tail binary?
$tail="/usr/bin/tail";
#Where is zcat binary?
$zcat="/bin/zcat";
$datentp="/usr/sbin/ntpdate";#delete
#Where is arping?
$arping_bin="/usr/bin/arping";
#Where is ping?
$ping_bin="/bin/ping";
#Where is openssl?
$openssl="/usr/bin/openssl";
#Where is unzip?
$unzip="/usr/bin/unzip";
#Where is mv?
$mv="/bin/mv";
#Where is ls?
$ls="/bin/ls";
#Where is cp?
$cp="/bin/cp";
#Where is iptables?
$iptables="/sbin/iptables";
#Where is modprobe?
$modprobe="/sbin/modprobe";
#Where is lsmod?
$lsmod="/sbin/lsmod";
#Where is gdnsd?
$gdnsd="/usr/sbin/gdnsd";
#Where is l4sd?
$l4sd="/opt/klb/app/l4s/bin/l4sd";#update
#Where is conntrack?
$conntrack="/usr/sbin/conntrack";
#Where is insserv?
$insserv="/sbin/insserv";

#where is pound binary?
$pound="/usr/sbin/pound";
#where is pound ctl?
$poundctl="/usr/sbin/poundctl";
#pound file configuration template?
$poundtpl="/opt/klb/app/pound/etc/poundtpl.cfg";#update
#piddir
$piddir="/var/run/";

## Network global configuration options ##
$rttables = "/etc/iproute2/rt_tables";
$fwmarksconf = "$configdir/fwmarks.conf";
#System Default Gateway
$defaultgw="";
#Interface Default Gateway
$defaultgwif="";
#Number of gratuitous pings
$pingc="1";

#Directory where is check script. In this directory you can save your own check scripts. 
$libexec_dir="/opt/klb/app/libexec";#update
#FarmGuardian binary, create advanced check for backend servers
$farmguardian="/opt/klb/app/farmguardian/bin/farmguardian";#update
#Directory where FarmGuadian save the logs
$farmguardian_logs="/opt/klb/logs";#update

#Where is ZenRRD Directory?. There is a perl script that create rrd database and images from Monitoring section
$rrdap_dir="/opt/klb/app/zenrrd/";#update
#Relative path in Web Root directory ($basedir) where is graphs from ZenRRD *no modify
$img_dir="/img/graphs/";
#Relative path where is rrd databases from ZenRRD * no modify
$rrd_dir="rrd/";
#File log name  for ZenRRD. A lot of disk space is needed. If it is blank no loggin
$log_rrd="";

#Zen service replication
$zenino="/opt/klb/app/zeninotify/zeninotify.pl"; #update
#Zen Inotify pid file 
$zeninopid="/var/run/zeninotify.pid";
#Zen inotify log file
$zeninolog="/opt/klb/logs/zeninotify.log";#update
#.<b>Rsync replication parameters</b>
$zenrsync="-auzv --delete";

#zen latency service start
$zenlatup="/opt/klb/app/zenlatency/zenlatency-start.pl";#update
#zen latency service stop
$zenlatdown="/opt/klb/app/zenlatency/zenlatency-stop.pl";#update
#Zen latency log file
$zenlatlog="/opt/klb/logs/zenlatency.log";#update

#Zen backup
$zenbackup="/opt/klb/app/zenbackup/zenbackup.pl";#update

#SNMP service
$snmpdconfig_file="/etc/snmp/snmpd.conf";
#::END Global Section

#!!!!NOT REMOVE NEXT LINE!!!!!!
1
