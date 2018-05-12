Karma Load Balancer
-------------------

KLB is a load balancing appliance based on the Debian Linux distribution.

As well as providing the full source on github, we regularly release an ISO
CDROM image for 64 bit Intel archiectures (currently based on Debian 8.6.0).
You should not try and co-host KLB with another OS on the same host as you may
loose your existing data.  Also ensure there are no USB sticks in the host
during installation for the same reason.

The installer will try and configure networking and the load balancer GUI will
start automatically after installation and can be access via a web browser on:
  <https://\<IP\>:444/>

The load balancer is designed to work in an active/passive cluster of two hosts
for high availability, however it can be run on a single node without the added
redundancy.

The default username and password for the GUI are both 'admin'.  You should
change the password after installation.  The root password is set to 'CHANGEiT'
and should also be changed after installation.  For ease of use you can sync
this with the admin password in the web GUI.

Network installation is also supported using the Debian netboot kernel and
initrd (instructions are available in the distro folder on github).

KLB is a fork of the Zen Load Balancer Community Edition
<https://www.zenloadbalancer.com/community/downloads/>
and tracks the Zevenet Load Balancer project
<https://github.com/zevenet/zlb>.

Links
-----
* Sources
    * <https://github.com/sgoldthorpe/karmalb>
* Binaries
    * <https://sourceforge.net/projects/karmalb/>
* Apt repo
    * deb http://apt.karmalb.org.uk/debian/ jessie main
* Email lists
    * <https://lists.sourceforge.net/lists/listinfo/karmalb-announce>
    * <https://lists.sourceforge.net/lists/listinfo/karmalb-developers>
    * <https://lists.sourceforge.net/lists/listinfo/karmalb-users>
* Discussion
    * <https://sourceforge.net/p/karmalb/discussion/>


Changelog
---------
* **1.0.1** - 12-May-2018 Minor Release _-Steve Goldthorpe_
    * pound upgraded from 2.7 -> 2.8
        * [Enhancement] removed DynScale flag and support
        * [Enhancement] removed support for multi-line headers (both input and output)
        * [Bug fix] fixed potential request smuggling via fudged headers
    * minihttpd upgraded from 1.27 -> 1.28
        * Fix to buffer overrun bug in htpasswd. Reported by Alessio Santoru as CVE-2017-17663.
        * Some fixes to keep connections from getting stuck forever in FIN_WAIT_2 state.
    * karmalb package now depends on pound >= 2.8 (and removes any DynScale settings)
    * Debian security updates since last release (in ISO image)

* **1.0.0r2** - 10-Oct-2017 ISO Image Update _-Steve Goldthorpe_
    * ISO update (rebase on Debian 8.10.0 + security updates)


* **1.0.0** - 15-Aug-2017 First Major Release _-Steve Goldthorpe_
    * Bugfix from zevenet zlb https://github.com/zevenet/zlb
        * Added netfilter lock when more than one iptables command is executed at the same time
    * ISO update (rebase on Debian 8.9.0 + security updates)

* **1.0beta4** - 03-Jun-2017 Fourth Beta Release _-Steve Goldthorpe_
    * Bugfixes and improvements from zevenet zlb https://github.com/zevenet/zlb
        * [New feature] Add advanced health check for SIP connections
        * [Improvement] Reset connexion tracking for udp in L4xNAT farms.
        * [Improvement] Reset connexion tracking for udp when backend is down by farmguardian.
        * [Bugfix] Problems with SIP on Manager
    * Increase default nf\_conntrack table
    * ISO update (rebase on Debian 8.8.0 + security updates)


* **1.0beta3** - 11-Mar-2017 Third Beta Release _-Steve Goldthorpe_
    * Web interface upgraded (mini\_httpd 1.26->1.27)
       * Fix version number (1.0b2 displayed 1.0b1)
       * Bugfix from zevenet zlb https://github.com/zevenet/zlb
           * [Bugfix] Secure system file paths while accessing to file logs
             through the web GUI
       * Debian security updates since last release (in ISO image)

* **1.0beta2** - 25-Feb-2017 Second Beta Release _-Steve Goldthorpe_
    * Bugfixes and improvements from zevenet zlb https://github.com/zevenet/zlb
        * [Bugfix] Missed farmname variable in contents
        * [Bugfix] Fix RewriteLocation always showing as disabled
        * [Improvement] direct access to farm details from overview.
        * [Improvement] click name to see details/edit.
    * Web interace upgraded (mini\_httpd 1.25->1.26) (minor non-linux fix)
    * Debian security updates since last release (in ISO image)
* **1.0beta1r1** - 21-Jan-2017 First Beta Release _-Steve Goldthorpe_
    * Added code to update /etc/issue with admin URL
    * ISO update (rebase on Debian 8.7.1 + security updates)
* **1.0alpha6r1** - 29-Sep-2016 Sixth Alpha Release _-Steve Goldthorpe_
    * Debian security updates since last release (in ISO image)
    * Enable SSLv1.0/SSLv1.1 disablement (A score available in ssllabs test)
    * Default lowest SSL protocol to SSLv1.1 for new farms
    * Strict cipher order set by default on new farms
    * Fix web interface log rotation
    * Web interface upgraded (mini\_httpd 1.23->1.25)
    * Bonded interface support to enable high availability/throughput
    * Visually indicate degraded slave interfaces
    * fix long-standing zen vulnerabilities (http://www.securityfocus.com/bid/55638)
    * Removed broken Net::Interface CPAN module (unused by KLB)
    * Sort order of farms and graphs
    * Load ip\_conntrack module at boot (fixes some Conn stats issues)
    * Show version on about tab as well as header
* **1.0alpha5r2** - 24-Sep-2016 Fifth Alpha Release _-Steve Goldthorpe_
    * ISO update only (rebase on Debian 8.6.0 + security updates)
* **1.0alpha5** - 06-Sep-2016 Fourth Alpha Release _-Steve Goldthorpe_
    * Debian security updates since last release (in ISO image) only
* **1.0alpha4** - 04-Jul-2016 Third Alpha Release _-Steve Goldthorpe_
    * Upgrade pound 2.6->2.7 (SSL DH keysize 1024->2048)
    * Remove RC4 from Default ciphers list
    * Extract backups using script with some checks
    * Add backup diff GUI function
    * ISO Image rebased on Debian 8.5.0 netinstall
    * Debian security updates since last release (in ISO image)
* **1.0alpha3** - 31-May-2016 Second Alpha Release _-Steve Goldthorpe_
    * Stop dhclient if found to be running
    * Assign IP for web GUI
    * Make reinstallation of karmalb package less painful
    * Remove obsolete config
    * Remove pen code
    * Add kernel/network tuning
    * Install irqbalance (will quit when not useful)
    * Use Chrony for time-sync rather than periodic ntpdate
    * Various branding changes
    * Many HTML/XHTML fixes
    * Update grub entry with name & version
    * Remove Issuer field in CSR creation
    * Debian security updates since last release (in ISO image)
* **1.0alpha2** - 7-May-2016 Initial Alpha Release _-Steve Goldthorpe_
    * public release.
