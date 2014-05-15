#!/bin/bash
###############################
##  cPanel Preinstall Check  ##
##  Version 1.2.0.2          ##
##  By: Matthew Vetter       ##
##      cPanel, Inc.         ##
###############################

# Color for Output
green='\e[0;32m'
red='\e[0;31m'
yellow='\e[0;33m'
NC='\e[0m' # No Color (if Not added, it will change the entire terminal output to the last color used)
#example echo -e "${green}Show in Green${NC}"

#Check if Perl Installed

echo -e "${yellow}=====PERL CHECK=====${NC}";

if perl < /dev/null > /dev/null 2>&1  ; then
        echo -e "${green}Perl is Installed. Nothing to Fix!${NC}"
    else
        echo -e "${red}Perl not Installed. You need to install this!${NC}";
        echo -e "     \_ To install perl run: yum install perl";
fi

#Check SELINUX Status

echo -e "${yellow}=====SELINUX CHECK=====${NC}";

selinuxfile="/etc/selinux/config"

if [ -f "$selinuxfile" ] ; then
    if ``cat "$selinuxfile" | grep "#SELINUX=" > /dev/null`` ; then
            echo -e "${red}SELINUX is commented out! You need to uncomment this (remove the # from in front of SELINUX) and set this to disabled!${NC}";
            echo -e "     \_ To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux and rebooting the server";
elif [ -f "$selinuxfile" ] ; then
    if ``cat "$selinuxfile" | grep "SELINUX=" | grep "enforcing" > /dev/null`` ; then
            echo -e "${red}SELINUX is set to enforcing! You need to set this to disabled!${NC}";
            echo -e "     \_ To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux and rebooting the server";
elif [ -f "$selinuxfile" ] ; then
    if ``cat "$selinuxfile" | grep "SELINUX=" | grep "permissive" > /dev/null`` ; then
            echo -e "${red}SELINUX is set to permissive! You need to set this to disabled!${NC}";
            echo -e "     \_ To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux and rebooting the server";
else
    echo -e "${green}Nothing to Fix. SELINUX appears to be disabled already!${NC}"
fi
fi
fi
fi

echo -e "${yellow}=====FIREWALL CHECK=====${NC}";

# Check if iptable disabled in chkconfig
if ``chkconfig --list | grep iptables | grep "0:off	1:off	2:off	3:off	4:off	5:off	6:off" > /dev/null`` ; then
        echo -e "${green}Firewall off in ChkConfig. Nothing to Fix!${NC}";
    elif ``chkconfig --list | grep iptables | grep "on" > /dev/null`` ; then
        echo -e "${red}Firewall enabled in ChkConfig. You should turn this off.${NC}";
        echo -e "     \_ To turn this off run: chkconfig iptables off";
fi

# Check if Firewall Running
if ``/etc/init.d/iptables status | grep "Table: filter" > /dev/null`` ; then
        echo -e "${red}Firewall Running. You should disable this.${NC}";
        echo -e "     \_ To disable this run: /etc/init.d/iptables save; /etc/init.d/iptables stop";
    elif ``/etc/init.d/iptables status | grep "Firewall is not running" > /dev/null`` ; then
        echo -e "${green}Firewall Not Running. Nothing to Fix!${NC}";
fi

# Check for Yum Groups All Versions (Group names the same accross all versions)

echo -e "${yellow}=====YUM GROUPS CHECK=====${NC}";

if ``echo -e "n" | yum groupremove "FTP Server" | grep "Removing:" > /dev/null`` ; then
        echo -e "${red}FTP Server is Installed. You should remove this${NC}";
        echo -e '     \_ To remove this run: yum groupremove "FTP Server"';
    else
        echo -e "${green}FTP Server - Fixed${NC}";
fi

if ``echo -e "n" | yum groupremove "Web Server" | grep "Removing:" > /dev/null`` ; then
        echo -e "${red}Web Server is Installed. You should remove this${NC}";
        echo -e '     \_ To remove this run: yum groupremove "Web Server"';
    else
        echo -e "${green}Web Server - Fixed${NC}";
fi

if ``echo -e "n" | yum groupremove "X Window System" | grep "Removing:" > /dev/null`` ; then
        echo -e "${red}X Window System is Installed. You should remove this${NC}";
        echo -e '     \_ To remove this run: yum groupremove "X Window System"';
    else
        echo -e "${green}X Window System - Fixed${NC}";
fi

# New Group Names CentOS/RHEL 6.*
if ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then

    if ``echo -e "n" | yum groupremove "E-mail Server" | grep "Removing:"  > /dev/null`` ; then
            echo -e "${red}E-mail Server is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "E-mail Server"';
        else
            echo -e "${green}E-Mail Server - Fixed${NC}";
    fi

    if ``echo -e "n" | yum groupremove "KDE Desktop" | grep "Removing:" > /dev/null`` ; then
            echo -e "${red}KDE Desktop is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "KDE Desktop"';
        else
            echo -e "${green}KDE Desktop - Fixed${NC}";
    fi

    if ``echo -e "n" | yum groupremove "Desktop" | grep "Removing:" > /dev/null`` ; then
            echo -e "${red}Gnome Desktop is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "Desktop"';
        else
            echo -e "${green}Gnome Desktop - Fixed${NC}";
    fi

fi

# Deprecated Group Names in CentOS/RHEL 6. Will check if on CentOS/RHEL 5.*

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then

    if ``echo -e "n" | yum groupremove "Mail Server" | grep "Removing:" | grep -v "No group named" > /dev/null`` ; then
            echo -e "${red}Mail Server is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "Mail Server"';
        else
            echo -e "${green}Mail Server - Fixed${NC}";
    fi

    if ``echo -e "n" | yum groupremove "GNOME Desktop Environment" | grep "Removing:" > /dev/null`` ; then
            echo -e "${red}GNOME Desktop Environment is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "GNOME Desktop Environment"';
        else
            echo -e "${green}GNOME Desktop Environment - Fixed${NC}";
    fi

    if ``echo -e "n" | yum groupremove "KDE (K Desktop Environment)" | grep "Removing:" > /dev/null`` ; then
            echo -e "${red}KDE (K Desktop Environment) is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "KDE (K Desktop Environment)"';
        else
            echo -e "${green}KDE (K Desktop Environment) - Fixed${NC}";
    fi

    if ``echo -e "n" | yum groupremove "Mono" | grep "Removing:" > /dev/null`` ; then
            echo -e "${red}Mono is Installed. You should remove this${NC}";
            echo -e '     \_ To remove this run: yum groupremove "Mono"';
        else
            echo -e "${green}Mono - Fixed${NC}";
    fi

fi

# FQDN Check

echo -e "${yellow}=====HOSTNAME FQDN CHECK=====${NC}"

hostname=`hostname`
{
    hostnameip=`curl http://cpanel.net/myip 2>/dev/null`
if [ $? -ne "0" ]; then
    hostnameip="0"
fi
}
fqdnhost=`hostname | grep -P '[a-zA-Z0-9]+[.]+[a-zA-Z0-9]+[.]+[a-zA-Z0-9]'`

if [[ $hostname = $fqdnhost ]]; then
        echo -e "${green}The server's hostname of $hostname is a FQDN${NC}"
    else
        echo -e "${red}The server's hostname of $hostname is not a FQDN${NC}"
fi

if [ $hostnameip != '0' ]; then
    digresult=`dig $hostname +short`

if [ ! -z "$digresult" ]; then
    if [ $digresult == $hostnameip ]; then
        echo -e "     \_ ${green}The IP the hostname resolves to is the same as what's set on the server${NC}"
    else
        echo -e "     \_ ${red}The hostname resolves to a different IP than what's set on the server${NC}"
        echo -e "     \_ ${red}The hostname should resolve to $hostnameip, but actually resolves to $digresult${NC}"
fi
    else
        echo -e "     \_ ${red}The hostname on the server does not resolve to an IP address${NC}"
fi
    else
        echo -e "     \_ ${red}The server's hostname is not in /etc/hosts!${NC}"
fi

# OS Check

echo -e "${yellow}=====SUPPORTED OS CHECK=====${NC}"

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then
            echo -e "${green}The OS is Supported${NC}";
            cat /etc/redhat-release;
elif ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then
            echo -e "${green}The OS is Supported${NC}";
            cat /etc/redhat-release;
else
        echo -e "${red}The OS is Not Supported${NC}";
        cat /etc/redhat-release;
fi