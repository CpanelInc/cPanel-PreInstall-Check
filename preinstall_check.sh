#!/bin/bash

# This script is a work in progress and should not be used on productions systems or any system you are worried about bricking. YOU HAVE BEEN WARNED.

# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0"  -o hcf: --long "help,check,fix"  -- "$@")
 
#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
  exit 1
fi
 
# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"
 
 
# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
while true;
do
  case "$1" in
 
    -h|--help)
      echo "--help shows this help dialouge";
      echo "--check checks status of preinstall requirements";
      echo "--fix fixes cpanel preinstall requirements";
     shift;;
 
    -c|--check)

#Check SELINUX Status
file="/etc/selinux/config"

if [ -f "$file" ] ; then
    if `cat "$file" | grep "SELINUX=" | grep "enforcing"` ; then
        echo "SELINUX is set to enforcing!";
elif [ -f "$file" ] ; then
        if `cat "$file" | grep "SELINUX=" | grep "permissive"` ; then
        echo "SELINUX is set to permissive!";
elif [ -f "$file" ] ; then
        if `cat "$file" | grep "#SELINUX="` ; then
        echo "SELINUX is commented out!";
else
    echo "Nothing to Fix. SELINUX appears to be disabled already!"
fi
fi
fi
fi

# Check if iptable disabled in chkconfig
if `chkconfig --list | grep iptables | grep "0:off	1:off	2:off	3:off	4:off	5:off	6:off"` ; then
        echo "Firewall off in ChkConfig. Nothing to Fix!";
elif `chkconfig --list | grep iptables | grep "on"` ; then
        echo "Firewall enabled in ChkConfig. You should turn this off.";
        echo "To turn this off run: chkconfig iptables off";
fi

# Check if Firewall Running      
if `/etc/init.d/iptables status | grep "Table: filter"` ; then
        echo "Firewall Running. You should disable this.";
        echo "To disable this run: /etc/init.d/iptables save; /etc/init.d/iptables stop";
elif `/etc/init.d/iptables status | grep "Firewall is not running"` ; then
        echo "Firewall Not Running. Nothing to Fix!";
fi

#Check if Perl Installed
if perl < /dev/null > /dev/null 2>&1  ; then
    echo "Perl is Installed on PATH. Nothing to Fix!"
else
    echo "Perl not Installed. You need to install this!";
    echo "To install perl run: yum install perl";
fi

# Check for Yum Groups All Versions (Group names the same accross all versions)

if ``echo "n" | yum groupremove "FTP Server" | grep "Removing:" > /dev/null`` ; then
    echo "FTP Server is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "FTP Server"';
elif ``echo "n" | yum groupremove "FTP Server" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "FTP Server is Not Installed";
fi

if ``echo "n" | yum groupremove "Web Server" | grep "Removing:" > /dev/null`` ; then
    echo "Web Server is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "Web Server"';
elif ``echo "n" | yum groupremove "Web Server" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "Web Server is Not Installed";
fi

if ``echo "n" | yum groupremove "X Window System" | grep "Removing:" > /dev/null`` ; then
    echo "X Window System is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "X Window System"';
elif ``echo "n" | yum groupremove "X Window System" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "X Window System is Not Installed";
fi

# New Group Names CentOS/RHEL 6.*
if ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then

if ``echo "n" | yum groupremove "E-mail Server" | grep "Removing:"  > /dev/null`` ; then
    echo "E-mail Server is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "E-mail Server"';
elif ``echo "n" | yum groupremove "E-mail Server" | grep "No packages to remove from groups"  > /dev/null`` ; then
    echo "=========="
    echo "E-Mail Server is Not Installed";
fi

if ``echo "n" | yum groupremove "KDE Desktop" | grep "Removing:" > /dev/null`` ; then
    echo "KDE Desktop is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "KDE Desktop"';
elif ``echo "n" | yum groupremove "KDE Desktop" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "KDE Desktop is Not Installed";
fi

if ``echo "n" | yum groupremove "Desktop" | grep "Removing:" > /dev/null`` ; then
    echo "Gnome Desktop is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "Desktop"';
elif ``echo "n" | yum groupremove "Desktop" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "Gnome Desktop is Not Installed";
fi

fi

# Deprecated Group Names in CentOS/RHEL 6. Will check if on CentOS/RHEL 5.*

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then

if ``echo "n" | yum groupremove "Mail Server" | grep "Removing:" | grep -v "No group named" > /dev/null`` ; then
    echo "Mail Server is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "Mail Server"';
elif ``echo "n" | yum groupremove "Mail Server" | grep "No packages to remove from groups" | grep -v "No group named"  > /dev/null`` ; then
    echo "=========="
    echo "Mail Server is Not Installed";
fi

if ``echo "n" | yum groupremove "GNOME Desktop Environment" | grep "Removing:" > /dev/null`` ; then
    echo "GNOME Desktop Environment is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "GNOME Desktop Environment"';
elif ``echo "n" | yum groupremove "GNOME Desktop Environment" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "GNOME Desktop Environment is Not Installed";
fi

if ``echo "n" | yum groupremove "KDE (K Desktop Environment)" | grep "Removing:" > /dev/null`` ; then
    echo "KDE (K Desktop Environment) is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "KDE (K Desktop Environment)"';
elif ``echo "n" | yum groupremove "KDE (K Desktop Environment)" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "KDE (K Desktop Environment) is Not Installed";
fi

if ``echo "n" | yum groupremove "Mono" | grep "Removing:" > /dev/null`` ; then
    echo "Mono is Installed. You should remove this";
    echo 'To remove this run: yum groupremove "Mono"';
elif ``echo "n" | yum groupremove "Mono" | grep "No packages to remove from groups" > /dev/null`` ; then
    echo "=========="
    echo "Mono is Not Installed";
fi

fi


shift;;

    -f|--fix)

# Stop Firewall

      /etc/init.d/iptables stop > /dev/null;
      echo "Firewall Stopped";

# Remove Yum Groups

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then

    yum -y groupremove "Mail Server" "GNOME Desktop Environment" "KDE (K Desktop Environment)" "Mono" "Web Server" "FTP Server" "X Window System";
    echo "Yum Groups Removed";

fi

if ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then

    yum -y groupremove "E-Mail Server" "Desktop" "KDE Desktop" "FTP Server" "Web Server" "X Window System";
    echo "Yum Groups Removed";

fi

shift;;

    -incp|--installcp)
	yum -y install wget;
	wget -N http://httpupdate.cpanel.net/latest;
	sh latest;
	shift;;

    -3|--three)
      echo "Tre"
      shift;;
 
    --)
      shift
      break;;
  esac
done
