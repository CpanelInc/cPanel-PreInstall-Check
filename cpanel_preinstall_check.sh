#!/bin/bash
###############################
##  cPanel Preinstall Check  ##
##  Version 1.1.2.02         ##
##  By: Matthew Vetter       ##
##      cPanel, Inc.         ##
###############################

#Check SELINUX Status

echo "=====SELINUX CHECK=====";

selinuxfile="/etc/selinux/config"

if [ -f "$selinuxfile" ] ; then
if ``cat "$selinuxfile" | grep "#SELINUX=" > /dev/null`` ; then
    echo "SELINUX is commented out! You need to uncomment this (remove the # from in front of SELINUX) and set this to disabled!";
    echo "==> To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux and rebooting the server";
elif [ -f "$selinuxfile" ] ; then
if ``cat "$selinuxfile" | grep "SELINUX=" | grep "enforcing" > /dev/null`` ; then
    echo "SELINUX is set to enforcing! You need to set this to disabled!";
    echo "==> To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux and rebooting the server";
elif [ -f "$selinuxfile" ] ; then
if ``cat "$selinuxfile" | grep "SELINUX=" | grep "permissive" > /dev/null`` ; then
    echo "SELINUX is set to permissive! You need to set this to disabled!";
    echo "==> To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux and rebooting the server";
else
    echo "Nothing to Fix. SELINUX appears to be disabled already!"
fi
fi
fi
fi

echo "=====FIREWALL CHECK=====";

# Check if iptable disabled in chkconfig
if ``chkconfig --list | grep iptables | grep "0:off	1:off	2:off	3:off	4:off	5:off	6:off" > /dev/null`` ; then
    echo "Firewall off in ChkConfig. Nothing to Fix!";
elif ``chkconfig --list | grep iptables | grep "on" > /dev/null`` ; then
    echo "Firewall enabled in ChkConfig. You should turn this off.";
    echo "==> To turn this off run: chkconfig iptables off";
fi

# Check if Firewall Running
if ``/etc/init.d/iptables status | grep "Table: filter" > /dev/null`` ; then
    echo "Firewall Running. You should disable this.";
    echo "==> To disable this run: /etc/init.d/iptables save; /etc/init.d/iptables stop";
elif ``/etc/init.d/iptables status | grep "Firewall is not running" > /dev/null`` ; then
    echo "Firewall Not Running. Nothing to Fix!";
fi

#Check if Perl Installed

echo "=====PERL CHECK=====";

if perl < /dev/null > /dev/null 2>&1  ; then
    echo "Perl is Installed. Nothing to Fix!"
else
    echo "Perl not Installed. You need to install this!";
    echo "==> To install perl run: yum install perl";
fi

# Check for Yum Groups All Versions (Group names the same accross all versions)

echo "=====YUM GROUPS CHECK=====";

if ``echo "n" | yum groupremove "FTP Server" | grep "Removing:" > /dev/null`` ; then
    echo "FTP Server is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "FTP Server"';
elif ``echo "n" | yum groupremove "FTP Server" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "FTP Server is Not Installed";
fi

if ``echo "n" | yum groupremove "Web Server" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "Web Server is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "Web Server"';
elif ``echo "n" | yum groupremove "Web Server" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "Web Server is Not Installed";
fi

if ``echo "n" | yum groupremove "X Window System" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "X Window System is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "X Window System"';
elif ``echo "n" | yum groupremove "X Window System" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "X Window System is Not Installed";
fi

# New Group Names CentOS/RHEL 6.*
if ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then

if ``echo "n" | yum groupremove "E-mail Server" | grep "Removing:"  > /dev/null`` ; then
    echo "=========="
    echo "E-mail Server is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "E-mail Server"';
elif ``echo "n" | yum groupremove "E-mail Server" | grep "No packages to remove from groups"  > /dev/null`` ; then
    echo "=========="
    echo "E-Mail Server is Not Installed";
fi

if ``echo "n" | yum groupremove "KDE Desktop" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "KDE Desktop is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "KDE Desktop"';
elif ``echo "n" | yum groupremove "KDE Desktop" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "KDE Desktop is Not Installed";
fi

if ``echo "n" | yum groupremove "Desktop" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "Gnome Desktop is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "Desktop"';
elif ``echo "n" | yum groupremove "Desktop" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "Gnome Desktop is Not Installed";
fi

fi

# Deprecated Group Names in CentOS/RHEL 6. Will check if on CentOS/RHEL 5.*

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then

if ``echo "n" | yum groupremove "Mail Server" | grep "Removing:" | grep -v "No group named" > /dev/null`` ; then
    echo "=========="
    echo "Mail Server is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "Mail Server"';
elif ``echo "n" | yum groupremove "Mail Server" | grep "No packages to remove from groups" | grep -v "No group named"  > /dev/null`` ; then
    echo "=========="
    echo "Mail Server is Not Installed";
fi

if ``echo "n" | yum groupremove "GNOME Desktop Environment" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "GNOME Desktop Environment is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "GNOME Desktop Environment"';
elif ``echo "n" | yum groupremove "GNOME Desktop Environment" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "GNOME Desktop Environment is Not Installed";
fi

if ``echo "n" | yum groupremove "KDE (K Desktop Environment)" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "KDE (K Desktop Environment) is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "KDE (K Desktop Environment)"';
elif ``echo "n" | yum groupremove "KDE (K Desktop Environment)" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "KDE (K Desktop Environment) is Not Installed";
fi

if ``echo "n" | yum groupremove "Mono" | grep "Removing:" > /dev/null`` ; then
    echo "=========="
    echo "Mono is Installed. You should remove this";
    echo '==> To remove this run: yum groupremove "Mono"';
elif ``echo "n" | yum groupremove "Mono" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "Mono is Not Installed";
fi

fi

# FQDN Check

echo "=====HOSTNAME FQDN CHECK====="

hostname=`hostname`
{
    hostnameip=`curl http://cpanel.net/myip 2>/dev/null`
if [ $? -ne "0" ]; then
    hostnameip="0"
fi
}
fqdnhost=`hostname | grep -P '[a-zA-Z0-9]+[.]+[a-zA-Z0-9]+[.]+[a-zA-Z0-9]'`

if [[ $hostname = $fqdnhost ]]; then
    echo "The server's hostname of $hostname is a FQDN"
else
    echo "The server's hostname of $hostname is not a FQDN"
fi

if [ $hostnameip != '0' ]; then
    digresult=`dig $hostname +short`

if [ ! -z "$digresult" ]; then
if [ $digresult == $hostnameip ]; then
    echo "The IP the hostname resolves to is the same as what's set on the server"
else
    echo "The hostname resolves to a different IP than what's set on the server"
    echo "The hostname should resolve to $hostnameip, but actually resolves to $digresult"
fi
else
    echo "The hostname on the server does not resolve to an IP address"
fi
else
    echo "The server's hostname is not in /etc/hosts!"
fi

# OS Check

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then
    cat /etc/redhat-release;
    echo "The OS is Supported";
elif ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then
    cat /etc/redhat-release;
    echo "The OS is Supported";
else
    cat /etc/redhat-release;
    echo "The OS is Not Supported";
fi