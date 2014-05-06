#!/bin/bash
############################
## cPanel Preinstall      ##
## Version 1.0.1          ##
## By: Matthew Vetter     ##
##     cPanel, Inc.       ##
############################

file="/etc/selinux/config"

if [ -f "$file" ] ; then
    if `cat "$file" | grep "SELINUX=" | grep -q "enforcing"` ; then
        sed -i '/^SELINUX=/s/\enforcing$/disabled/' "$file";
        echo "SELINUX set from enforcing to disabled!";
        cat /etc/selinux/config | grep "SELINUX=" | grep -v "# SELINUX";
elif [ -f "$file" ] ; then
        if `cat "$file" | grep "SELINUX=" | grep -q "permissive"` ; then
        sed -i '/^SELINUX=/s/\permissive$/disabled/' "$file";
        echo "SELINUX set from permissive to disabled!";
        cat /etc/selinux/config | grep "SELINUX=" | grep -v "# SELINUX";
elif [ -f "$file" ] ; then
        if `cat "$file" | grep "#SELINUX="` ; then
        sed -i 's/#SELINUX=.*/SELINUX=disabled/g' "$file";
        echo "SELINUX set from commented out to disabled!";
        cat /etc/selinux/config | grep "SELINUX=" | grep -v "# SELINUX";
else
    echo "Nothing to fix! (SELINUX appears to be disabled already)"
    cat /etc/selinux/config | grep "SELINUX=" | grep -v "# SELINUX";
fi
fi
fi
fi

echo "==========";

#Turn off Firewall
chkconfig iptables off;
service iptables stop;
echo "==========";
echo "Firewall Disabled and Turned Off!";
echo "==========";

#Remove Yum Groups
yum -y groupremove "FTP Server" "GNOME Desktop Environment" "KDE (K Desktop Environment)" "Mail Server or E-mail Server" "Mono" "Web Server" "X Window System";
echo "==========";
echo "Yum Groups Removed or Already Removed!";
echo "==========";

# Install Perl
yum -y install perl;
echo "==========";
echo "Perl Installed or Already Installed!";
echo "==========";
echo "Server is Ready to Reboot and Re-Install cPanel!";

yum -y install wget;
wget -N http://httpupdate.cpanel.net/latest;
sh latest;
echo "==========";
echo "cPanel Installed. Make sure to reboot the server to finish disabling SELINUX";
