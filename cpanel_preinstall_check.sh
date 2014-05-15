#!/bin/bash
###############################
##  cPanel Preinstall Check  ##
##  Version 1.2.2.2          ##
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
        echo -e "${green}Perl is Installed - Pass${NC}"
        echo -e "\t \_ Perl `perl -v | grep 'This is perl, v'| awk '{print $4}'` Installed - Verify this is a Supported Version"
            if ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then
                echo -e "\t \_ Latest version in Yum is - Perl `yum info perl | grep Version | awk '{print $3}'`"
            elif ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then
                echo -e "\t \_ Latest version in Yum is - Perl ` yum info perl | awk '/Installed Packages/ {flag=1;next} /Available Packages/{flag=0} flag {print}' | grep Version | awk '{print $2}'`"
            fi
    else
        echo -e "${red}Perl not Installed - Fail${NC}";
        echo -e "\t \_ To install perl run: yum install perl";
fi

#Check SELINUX Status

echo -e "${yellow}=====SELINUX CHECK=====${NC}";

selinuxfile="/etc/selinux/config"

if [ -f "$selinuxfile" ] ; then
    if ``cat "$selinuxfile" | grep "#SELINUX=" > /dev/null`` ; then
            echo -e "${red}SELINUX - Fail${NC}";
            echo -e "\t \_ SELINUX is commented out!"
            echo -e "\t \_ To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux, uncommenting SELINUX (remove the # from in front of SELINUX), setting it to disabled and then rebooting the server";
elif [ -f "$selinuxfile" ] ; then
    if ``cat "$selinuxfile" | grep "SELINUX=" | grep "enforcing" > /dev/null`` ; then
            echo -e "${red}SELINUX - Fail${NC}";
            echo -e "\t \_ SELINUX is set to enforcing!"
            echo -e "\t \_ To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux, setting it to disabled and then rebooting the server";
elif [ -f "$selinuxfile" ] ; then
    if ``cat "$selinuxfile" | grep "SELINUX=" | grep "permissive" > /dev/null`` ; then
            echo -e "${red}SELINUX - Fail${NC}";
            echo -e "\t \_ SELINUX is set to permissive!"
            echo -e "\t \_ To fix this please review the following article http://www.cyberciti.biz/faq/howto-turn-off-selinux/ and apply the permanent fix by editing /etc/sysconfig/selinux, setting it to disabled and then rebooting the server";
else
    echo -e "${green}SELINUX - Pass${NC}";
    echo -e "\t \_ SELINUX appears to be disabled already";
fi
fi
fi
fi

echo -e "${yellow}=====FIREWALL CHECK=====${NC}";

# Check if iptable disabled in chkconfig
if ``chkconfig --list | grep iptables | grep "0:off	1:off	2:off	3:off	4:off	5:off	6:off" > /dev/null`` ; then
        echo -e "${green}Firewall off in ChkConfig - Pass${NC}";
    elif ``chkconfig --list | grep iptables | grep "on" > /dev/null`` ; then
        echo -e "${red}Firewall enabled in ChkConfig - Fail${NC}";
        echo -e "\t \_ To turn this off run: chkconfig iptables off";
fi

# Check if Firewall Running
if ``/etc/init.d/iptables status | grep "Table: filter" > /dev/null`` ; then
        echo -e "${red}Firewall Running - Fail${NC}";
        echo -e "\t \_ To disable this run: /etc/init.d/iptables save; /etc/init.d/iptables stop";
    elif ``/etc/init.d/iptables status | grep "Firewall is not running" > /dev/null`` ; then
        echo -e "${green}Firewall Not Running - Pass${NC}";
fi

# Check for Yum Groups All Versions (Group names the same accross all versions)

echo -e "${yellow}=====YUM GROUPS CHECK=====${NC}";

if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "FTP server" > /dev/null`` ; then
        echo -e "${red}FTP Server - Fail${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "FTP Server"';
    else
        echo -e "${green}FTP Server - Pass${NC}";
fi

if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Web Server" > /dev/null`` ; then
        echo -e "${red}Web Server - Fail${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "Web Server"';
    else
        echo -e "${green}Web Server - Pass${NC}";
fi

if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "X Window System" > /dev/null`` ; then
        echo -e "${red}X Window System - Fail${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "X Window System"';
    else
        echo -e "${green}X Window System - Pass${NC}";
fi

# New Group Names CentOS/RHEL 6.*
if ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "E-mail server" > /dev/null`` ; then
            echo -e "${red}E-mail Server - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "E-mail Server"';
        else
            echo -e "${green}E-Mail Server - Pass${NC}";
    fi

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "KDE Desktop" > /dev/null`` ; then
            echo -e "${red}KDE Desktop - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "KDE Desktop"';
        else
            echo -e "${green}KDE Desktop - Pass${NC}";
    fi

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Desktop" > /dev/null`` ; then
            echo -e "${red}Gnome Desktop - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "Desktop"';
        else
            echo -e "${green}Gnome Desktop - Pass${NC}";
    fi

fi

# Deprecated Group Names in CentOS/RHEL 6. Will check if on CentOS/RHEL 5.*

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Mail Server" > /dev/null``; then
            echo -e "${red}Mail Server - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "Mail Server"';
        else
            echo -e "${green}Mail Server - Pass${NC}";
    fi

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "GNOME Desktop Environment" > /dev/null``; then
            echo -e "${red}GNOME Desktop Environment - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "GNOME Desktop Environment"';
        else
            echo -e "${green}GNOME Desktop Environment - Pass${NC}";
    fi

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "KDE (K Desktop Environment)" > /dev/null`` ; then
            echo -e "${red}KDE (K Desktop Environment) - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "KDE (K Desktop Environment)"';
        else
            echo -e "${green}KDE (K Desktop Environment) - Pass${NC}";
    fi

    if ``yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Mono" > /dev/null`` ; then
            echo -e "${red}Mono - Fail${NC}";
            echo -e '\t \_ To remove this run: yum groupremove "Mono"';
        else
            echo -e "${green}Mono - Pass${NC}";
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
        echo -e "\t \_ ${green}The IP the hostname resolves to is the same as what's set on the server${NC}"
    else
        echo -e "\t \_ ${red}The hostname resolves to a different IP than what's set on the server${NC}"
        echo -e "\t \_ ${red}The hostname should resolve to $hostnameip, but actually resolves to $digresult${NC}"
fi
    else
        echo -e "\t \_ ${red}The hostname on the server does not resolve to an IP address${NC}"
fi
    else
        echo -e "\t \_ ${red}The server's hostname is not in /etc/hosts!${NC}"
fi

# OS & Kernel Check

echo -e "${yellow}=====SUPPORTED OS CHECK=====${NC}"

if ``cat /etc/redhat-release | grep "release 5.*" > /dev/null``  ; then
            echo -e "${green}The OS is Supported${NC}";
            echo -e "\t \_`cat /etc/redhat-release`"
elif ``cat /etc/redhat-release | grep "release 6.*" > /dev/null``  ; then
            echo -e "${green}The OS is Supported${NC}";
            echo -e "\t \_`cat /etc/redhat-release`"
else
        echo -e "${red}The OS is Not Supported${NC}";
        echo -e "\t \_`cat /etc/redhat-release`"
fi

if ``cat kernel | grep "grs" > /dev/null``; then
        echo -e "${red}Kernel Not Supported${NC}";
        echo -e "\t \_ GRSEC Kernels are Not Supported";
        echo -e "\t \_ `uname -r`";
    elif ``cat kernel | grep -P "2.[0-9]." > /dev/null`` ; then
        echo -e "${green}Kernel Supported${NC}";
        echo -e "\t \_ `uname -r`";
    else
        echo -e "${red}Kernel Not Supported${NC}";
        echo -e "\t \_ `uname -r`";
fi
