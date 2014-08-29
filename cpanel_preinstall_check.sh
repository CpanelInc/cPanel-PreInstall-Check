#!/bin/bash
###############################
##  cPanel Preinstall Check  ##
##  Version 1.2.10           ##
##  By: Matthew Vetter       ##
##      cPanel, Inc.         ##
###############################

# Color for Output
green='\e[0;32m'
red='\e[0;31m'
yellow='\e[0;33m'
NC='\e[0m' # No Color (if Not added, it will change the entire terminal output to the last color used)
#example echo -e "${green}[PASS] * Show in Green${NC}"

# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0"  -o hnif --long "help,nocolor,install,force-install"  -- "$@")

#Bad arguments, something has gone wrong with the getopt command.
if [ $? -ne 0 ];
then
   echo "That is not a valid option. Please use --help to find a list of valid options."
   exit 0
fi

# A little magic, necessary when using getopt.
eval set -- "$PARSED_OPTIONS"

# Now goes through all the options with a case and using shift to analyse 1 argument at a time.
#$1 identifies the first argument, and when we use shift we discard the first argument, so $2 becomes $1 and goes again through the case.
while true;
do
    case "$1" in

    -h|--help)
        echo "-h / --help : Displays this screen";
        echo "-n / --nocolor : Runs Script without Color Output";
        echo "-i / --install : Grabs the cPanel Installer and Runs it.";
        echo "-f / --force-install : Grabs the cPanel Installer and Forces it to run for RHEL 5 based machines";           
        exit 0;
    shift;;

    -n|--nocolor)
        #disables color output
        green='\e[0m'
        red='\e[0m'
        yellow='\e[0m'
        NC='\e[0m'
    shift;;

    -i|--install)
        if `grep "release 5.*" /etc/redhat-release > /dev/null`  ; then
            echo -e "${yellow}[WARN] * `awk '{print $1, $3}' /etc/redhat-release` (Linux) detected!${NC}"
            echo -e "[INFO] * In order to take full advantage of all the features provided by cPanel & WHM, such as multiple SSL Certificates on a single IPv4 Address, we highly recommend you use `awk '{print $1}' /etc/redhat-release` 6.x."
            echo -e "[INFO] * You can force the install on `awk '{print $1, $3}' /etc/redhat-release` using the --force-install option."      
        elif `grep "release 6.*" /etc/redhat-release > /dev/null`  ; then
            if command -v wget >/dev/null 2>&1  ; then
                cd /root/;
                mv latest{,.bak.`date +%Y-%m-%d-%H:%M:%S`};
                wget http://httpupdate.cpanel.net/latest;
                sh latest;
            else
                echo -e "wget is not installed, cannot run installer. Please install wget with 'yum install wget'"
            fi
        fi
        exit 0;
    shift;;

    -f|--force-install)
        if command -v wget >/dev/null 2>&1  ; then
            cd /root/;
            mv latest{,.bak.`date +%Y-%m-%d-%H:%M:%S`};
            wget http://httpupdate.cpanel.net/latest;
            sh latest --force;
        else
            echo -e "wget is not installed, cannot run installer. Please install wget with 'yum install wget'"
        fi
        exit 0;
    shift;;    

    --)
    shift
    break;;
    esac
done

#Check if cPanel Install Present
echo -e "====== cPanel Install CHECK ======";

if ls /usr/local/cpanel >/dev/null 2>&1 || ls /var/cpanel >/dev/null 2>&1 || command -v /etc/init.d/cpanel >/dev/null 2>&1 ; then
    echo -e "${red}[FAIL] * cPanel Installation Found${NC}"
    if ls /usr/local/cpanel >/dev/null 2>&1; then
        echo -e "\t \_ cPanel/WHM `cat /usr/local/cpanel/version` Install Detected"
        echo -e "\t \_ You will need to start with a fresh OS install / reinstall the OS before installing cPanel"
    else
        echo -e "\t \_ Previous cPanel Installation/Removal Detected"
        echo -e "\t \_ You will need to start with a fresh OS install / reinstall the OS before installing cPanel"
    fi
else
    echo -e "${green}[PASS] * cPanel not Installed${NC}"
fi

#Check if Perl Installed
echo -e "====== PERL CHECK ======";

if perl < /dev/null > /dev/null 2>&1  ; then
    echo -e "${green}[PASS] * Perl is Installed${NC}";
    echo -e "\t \_ Perl `perl -v | grep 'This is perl, v'| awk '{print $4}'` Installed - Verify this is a Supported Version";
    if `grep "release 6.*" /etc/redhat-release > /dev/null`  ; then
        echo -e "\t \_ Latest version in Yum is - Perl `yum info perl | grep Version | awk '{print $3}'`";
    elif `grep "release 5.*" /etc/redhat-release > /dev/null`  ; then
        echo -e "\t \_ Latest version in Yum is - Perl ` yum info perl | awk '/Installed Packages/ {flag=1;next} /Available Packages/{flag=0} flag {print}' | grep Version | awk '{print $3}'`";
    fi
else
    echo -e "${red}[FAIL] * Perl not Installed${NC}";
    echo -e "\t \_ To install perl run: yum install perl";
fi

#Check if wget Installed
echo -e "====== WGET CHECK ======";

if command -v wget >/dev/null 2>&1  ; then
    echo -e "${green}[PASS] * wget is Installed${NC}";
else
    echo -e "${red}[FAIL] * wget not Installed${NC}";
    echo -e "\t \_ To install wget run: yum install wget";
fi

#Check SELINUX Status
echo -e "====== SELINUX  CHECK ======";

if `grep "#SELINUX=" /etc/selinux/config > /dev/null` ; then
    echo -e "${red}[FAIL] * SELINUX${NC}";
    echo -e "\t \_ SELINUX is commented out!"
    echo -e "\t \_ To fix this edit /etc/sysconfig/selinux, uncomment SELINUX= (remove the # from in front of SELINUX), sett it to disabled and then reboot the server";
elif `sestatus | grep "enabled" > /dev/null` ; then 
    echo -e "${red}[FAIL] * SELINUX${NC}";
    echo -e "\t \_ Selinux is Enabled and is currently set to `sestatus | grep 'Current mode' | awk '{print $3}'`";

    if `sestatus | grep "Mode from config file:" | grep "disabled" > /dev/null`; then 
        echo -e "\t \_ However Selinux is set to disabled in the config file. The server needs to be rebooted to apply the change";
    else
        echo -e "\t \_ To fix this edit /etc/sysconfig/selinux, set SELINUX= to disabled and then reboot the server";     
    fi
elif `sestatus | grep "disabled" > /dev/null` ; then 
    echo -e "${green}[PASS] * SELINUX${NC}";
    echo -e "\t \_ SELINUX appears to be disabled already";
fi

# Check for Yum Groups All Versions (Group names the same accross all versions)
echo -e "====== YUM GROUPS CHECK ======";

if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "FTP server" > /dev/null` ; then
    echo -e "${red}[FAIL] * FTP Server${NC}";
    echo -e '\t \_ To remove this run: yum groupremove "FTP Server"';
else
    echo -e "${green}[PASS] * FTP Server${NC}";
fi

if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Web Server" > /dev/null` ; then
    echo -e "${red}[FAIL] * Web Server${NC}";
    echo -e '\t \_ To remove this run: yum groupremove "Web Server"';
else
    echo -e "${green}[PASS] * Web Server${NC}";
fi

if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "X Window System" > /dev/null` ; then
    echo -e "${red}[FAIL] * X Window System${NC}";
    echo -e '\t \_ To remove this run: yum groupremove "X Window System"';
else
    echo -e "${green}[PASS] * X Window System${NC}";
fi

if `rpm -qa | grep -i courier >  /dev/null`; then
    echo -e "${red}[FAIL] * Courier E-mail Server${NC}";
    echo -e "\t \_ To remove this run: rpm -e --nodeps `rpm -qa | grep -i courier`";
else
    echo -e "${green}[PASS] * Courier E-Mail Server${NC}";
fi

# New Group Names CentOS/RHEL 6.*
if `grep "release 6.*" /etc/redhat-release > /dev/null`  ; then

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "E-mail server" > /dev/null` ; then
        echo -e "${red}[FAIL] * E-mail Server${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "E-mail Server"';
    else
        echo -e "${green}[PASS] * E-Mail Server${NC}";
    fi

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "KDE Desktop" > /dev/null` ; then
        echo -e "${red}[FAIL] * KDE Desktop${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "KDE Desktop"';
    else
        echo -e "${green}[PASS] * KDE Desktop${NC}";
    fi

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Desktop" > /dev/null` ; then
        echo -e "${red}[FAIL] * Gnome Desktop${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "Desktop"';
    else
        echo -e "${green}[PASS] * Gnome Desktop${NC}";
    fi

elif `grep "release 5.*" /etc/redhat-release > /dev/null`  ; then

    # Deprecated Group Names in CentOS/RHEL 6. Will check if on CentOS/RHEL 5.*

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Mail Server" > /dev/null`; then
        echo -e "${red}[FAIL] * Mail Server${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "Mail Server"';
    else
        echo -e "${green}[PASS] * Mail Server${NC}";
    fi 

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "GNOME Desktop Environment" > /dev/null`; then
        echo -e "${red}[FAIL] * GNOME Desktop Environment${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "GNOME Desktop Environment"';
    else
        echo -e "${green}[PASS] * GNOME Desktop Environment${NC}";
    fi

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "KDE (K Desktop Environment)" > /dev/null` ; then
        echo -e "${red}[FAIL] * KDE (K Desktop Environment)${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "KDE (K Desktop Environment)"';
    else
        echo -e "${green}[PASS] * KDE (K Desktop Environment)${NC}";
    fi

    if `yum grouplist | awk '/Installed Groups:/ {flag=1;next} /Available Groups:/{flag=0} flag {print}' | grep "Mono" > /dev/null` ; then
        echo -e "${red}[FAIL] * Mono${NC}";
        echo -e '\t \_ To remove this run: yum groupremove "Mono"';
    else
        echo -e "${green}[PASS] * Mono${NC}";
    fi

fi

# FQDN Check
echo -e "====== HOSTNAME CHECK ======";

hostname=`hostname`
{
    hostnameip=`curl http://cpanel.net/myip 2>/dev/null`
if [ $? -ne "0" ]; then
    hostnameip="0"
fi
}
fqdnhost=`hostname | grep -P '[a-zA-Z0-9]+[.]+[a-zA-Z0-9]+[.]+[a-zA-Z0-9]'`

if [[ $hostname = $fqdnhost ]]; then
echo -e "${green}[PASS] * The server's hostname of $hostname is a FQDN${NC}"
else
echo -e "${red}[FAIL] * The server's hostname of $hostname is not a FQDN${NC}"
echo -e "\t \_ To fix this edit /etc/sysconfig/network and replaced the hostname on the HOSTNAME= line and reboot the server"
echo -e "\t \_ For example a FQDN should look like server.domain.com or server.domain.co.uk"
fi

if dig < /dev/null > /dev/null 2>&1  ; then

    if [ $hostnameip != '0' ]; then
        digresult=`dig $hostname +short`

        if [ ! -z "$digresult" ]; then
            if [ $digresult == $hostnameip ]; then
                echo -e "${green}[PASS] * The IP the hostname resolves to is the same as what's set on the server${NC}"
            else
                echo -e "${yellow}[WARN] * The hostname resolves to a different IP than what's set on the server${NC}"
                echo -e "\t \_ The hostname should resolve to $hostnameip, but actually resolves to $digresult${NC}"
                echo -e "\t \_ To fix this edit the A record in DNS for the hostname and point it to this servers primary IP $hostnameip" 
            fi
        else
            echo -e "${yellow}[WARN] * The hostname on the server does not resolve to an IP address${NC}"
            echo -e "\t \_ To fix this add an A record to DNS for the hostname and point it to the servers primary IP $hostnameip"
        fi
    else
        echo -e "${yellow}[WARN] * The server's hostname is not in /etc/hosts!${NC}"
        echo -e "\t \_ To fix this edit /etc/hosts and use the following example below, replacing server.domain.com with your hostname"
        echo -e "\t \_ $hostnameip server.domain.com"
    fi
else
    echo -e "${yellow}[WARN] * Can't check if hostname resolves to an IP because Dig is not installed.${NC}"
    echo -e "\t \_ To install dig run: yum install bind-utils"
fi

# OS & Kernel Check
echo -e "====== OS & KERNEL CHECKS ======";

if `grep "release 5.*" /etc/redhat-release > /dev/null`  ; then
    echo -e "${green}[PASS] * The OS is Supported${NC}";
    echo -e "\t \_ `cat /etc/redhat-release`"
elif `grep "release 6.*" /etc/redhat-release > /dev/null`  ; then
    echo -e "${green}[PASS] * The OS is Supported${NC}";
    echo -e "\t \_ `cat /etc/redhat-release`"
else
    echo -e "${red}[FAIL] * The OS is Not Supported${NC}";
    echo -e "\t \_ `cat /etc/redhat-release`"
fi

if `runlevel | awk '{print $2}' | grep 3 > /dev/null`; then 
    echo -e "${green}[PASS] * OS Run Level is 3${NC}";
else 
    echo -e "${red}[FAIL] * OS Run Level is `runlevel | awk '{print $2}'`${NC}";
    echo -e "\t \_ To fix this run: init 3";
fi

if  `stat -c "%a %n" /tmp | awk '{print $1}' | grep 1777 > /dev/null`; then
    echo -e "${green}[PASS] * /tmp is set to 1777 permissions${NC}";
else 
    echo -e "${red}[FAIL] * /tmp is set to `stat -c "%a %n" /tmp | awk '{print $1}'`${NC}";
    echo -e "\t \_ To fix this run: chmod 1777 /tmp";
fi

if [[ `free -m | grep "Mem:" | awk '{print $2}'` < 500 ]];then
    echo -e "${green}[PASS] * System Memory Higher than 500MB${NC}";
else     
    echo -e "${red}[FAIL] * System Memory Lower than 500MB${NC}";
    echo -e "Please install at least 500MB to 1GB of Memory before using cPanel";
fi

if `uname -r | grep "grs" > /dev/null`; then
    echo -e "${red}[FAIL] * Kernel Not Supported${NC}";
    echo -e "\t \_ GRSEC Kernels are Not Supported";
    echo -e "\t \_ `uname -r`";
elif `uname -r | grep -i "xx" > /dev/null`; then
    echo -e "${red}[FAIL] * Kernel Not Supported${NC}";
    echo -e "\t \_ GRSEC Kernels are Not Supported";
    echo -e "\t \_ `uname -r`";
elif `uname -r | grep -P "2.[0-9]." > /dev/null` ; then
    echo -e "${green}[PASS] * Kernel Supported${NC}";
    echo -e "\t \_ `uname -r`";
else
    echo -e "${red}[FAIL] * Kernel Not Supported${NC}";
    echo -e "\t \_ `uname -r`";
fi

