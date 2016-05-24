eval 'if [ ! -e /usr/bin/perl ] ; then yum install -y perl > /dev/null; echo "Perl was missing, so we installed it."; fi; if [ -x /usr/bin/perl ]; then exec /usr/bin/perl -x $0 ${1+"$@"}; fi;'
if 0;

#!/usr/bin/perl
###############################
##  cPanel Preinstall Check  ##
##  Version 1.4.0            ##
##  By: Matthew Vetter       ##
###############################

use Getopt::Long;

my $green  = "\e[0;32m";
my $red    = "\e[0;31m";
my $yellow = "\e[0;33m";
my $NC     = "\e[0m";
my $UL     = "\e[4m";
my $UE     = "\e[0m";

#Let's make sure /etc/redhat-release exists before proceeding
if ( -e "/etc/redhat-release" ) {
    $rhelexists = "yes";
}
else {
    print "${yellow}[WARN]\t \\_ /etc/redhat-release is missing. Are you running CentOS or RedHat?${NC}\n";
    print "\t \\_ To run cPanel and this script you must be running CentOS or RedHat Enterprise Linux!\n";
    exit 0;
}

#Don't Move, Else We Break the Install Switches.
my $rhel5  = `grep "release 5.*" /etc/redhat-release`;
my $rhel6  = `grep "release 6.*" /etc/redhat-release`;
my $rhel7  = `grep "release 7.*" /etc/redhat-release`;
my $amazon = `grep -i "Amazon" /etc/os-release`;
my $bit32  = `uname -a | grep "i686\|i386"`;
chomp( my $rhel      = `awk '{print \$1, \$3}' /etc/redhat-release` );
chomp( my $rhel7prnt = `awk '{print \$1, \$4}' /etc/redhat-release` );
chomp( my $rhelrec   = `awk '{print \$1}' /etc/redhat-release` );

print "========================================================================================================================\n";

my $nocolor      = 0;
my $fixit        = 0;
my $help         = 0;
my $install      = 0;

GetOptions(
    'nocolor'       => sub { $nocolor      = 1 },
    'fix|okdoit'    => sub { $fixit        = 1 },
    'help|h|option' => sub { $help         = 1 },
    'install'       => sub { $install      = 1 }
);

if ( $help == 1 ) {
    print "-h / --help : Displays this screen\n";
    print "--nocolor : Runs Script without Color Output\n";
    print "--install : Grabs the cPanel Installer and Runs it.\n";
    print "--fix: Fix issues detected in checks.\n";
    print "========================================================================================================================\n";
    exit 0;
}
if ( $nocolor == 1 ) {
    $green  = "\e[0m";
    $red    = "\e[0m";
    $yellow = "\e[0m";
    $NC     = "\e[0m";
}
if ( $install == 1 ) {
    if ( $rhel5 || $bit32 ) {
        print "${red}[FAIL] * $rhel (Linux) / 32-bit OS detected!${NC}\n";
        print "[INFO] * cPanel no longer supports RHEL 5 or 32 bits systems. Please upgrade to CentOS 6 64-bit or CentOS 7 64-bit\n";
    }
    elsif ( $rhel6 || rhel7 ) {
        &cpinstall;
    }
    print "========================================================================================================================\n";

    exit 0;
}

print "cPanel Preinstall Check\n";
print "[Version] 1.4.0\n";
print "[Updated] May 24th 2016\n";
print "[INFO] * This script has been deprecated and updates may no longer occur. Please utilize the cPanel Installer.\n";
print "[INFO] * You can run the installer from this script using --install or download it manually.\n";

cpanelchk();

#resolvechk();

chomp( my $perlrhel6   = `yum info perl 2>/dev/null | awk '/Version/{print \$3}'` );
chomp( my $perlrhel5   = `yum info perl 2>/dev/null | awk '/Installed Packages/ {flag=1;next} /Available Packages/{flag=0} flag {print}'  | awk '/Version/{print \$3}'` );
chomp( my $selinuxmode = `sestatus | awk '/Current mode:/ {print \$3}'` );
chomp( my $cpversion   = `[ -e /usr/local/cpanel/version ] && awk '{print \$1}' /usr/local/cpanel/version` );

#perlchk();
wgetchk();
selinuxchk();
yumgroupchk();
hostnamechk();
oskernelchk();

if ($failed) {
    if ( !$fixit ) {
        print "\n${yellow}[INFO] * YOU CAN FIX FAILURES/WARNINGS BY RE-RUNNING THE SCRIPT WITH --fix${NC}\n";
    }
}

print "\n========================================================================================================================\n";

#Sub Routines
sub cpinstall {
    if (`wget --help`) {
        chdir "/root/" or die "Cannot change to root\n";
        rename "latest" => "latest.bak";
        system("wget http://httpupdate.cpanel.net/latest");
        system("sh latest");
    }
    else {
        print "wget is not installed, cannot run installer. Please install wget with 'yum install wget'\n";
    }
}

sub cpanelchk {
    print "\n${UL}cPanel Install CHECK:${UE}\n";
    if ( -e "/usr/local/cpanel" || -e "/var/cpanel" || -e "/etc/init.d/cpanel" ) {
        print "${red}[FAIL] * cPanel Installation Found${NC}\n";
        if ( -e "/usr/local/cpanel" ) {
            print "\t \\_ cPanel/WHM $cpversion Install Detected\n";
            print "\t \\_ You will need to start with a fresh OS install / reinstall the OS before installing cPanel\n";
        }
        else {
            print "\t \_ Previous cPanel Installation/Removal Detected\n";
            print "\t \_ You will need to start with a fresh OS install / reinstall the OS before installing cPanel\n";
        }
        print "========================================================================================================================\n";
        exit 0;
    }
    else {
        print "${green}[PASS] * cPanel not Installed${NC}\n";

    }
}

#No Longer Output
sub perlchk {
    print "\n${UL}PERL CHECK:${UE}\n";
    print "${green}[PASS] * Perl Installed${NC}\n";
    if ($rhel6) {
        print "\t \\_ Latest version in Yum is - Perl $perlrhel6\n";
    }
    elsif ($rhel5) {
        print "\t \\_ Latest version in Yum is - Perl $perlrhel5\n";
    }
    else {
        print "${red}[FAIL] * Perl is not installed.${NC}\n";
        print "\t \\_ To install perl run: yum install perl\n";
    }
}

sub wgetchk {
    print "\n${UL}WGET CHECK:${UE}\n";
    if (`wget --help`) {
        print "${green}[PASS] * wget is Installed${NC}\n";
        $wgetpass = "yes";
    }
    else {
        print "${red}[FAIL] * wget not Installed${NC}\n";
        $failed = "yes";
    }

    if ( $fixit == 1 ) {
        if ( !$wgetpass ) {
            print "Would you like to fix this? Y or N: ";
            my $answer = <STDIN>;
            chomp($answer);
            if ( $answer =~ m/^y$|^yes$/i ) {
                system("yum -y install wget > /dev/null");
                if (`wget --help`) {
                    print "\t \\_ wget was installed succesfully\n";
                }
                else {
                    print "\t \\_ wget was not installed succesfully. To fix manually install with: yum install wget\n";
                }
            }
            else {
                print "\t \\_ To fix manually install wget with: yum install wget\n";
            }
        }
    }
}

sub selinuxchk {
    print "\n${UL}SELINUX  CHECK:${UE}\n";

    if (`grep "#SELINUX=" /etc/selinux/config`) {
        print "${red}[FAIL] * SELINUX${NC}\n";
        print "\t \\_ SELINUX is commented out!\n";
        if ( $fixit == 1 ) {
            print "\t \\_ To fix this edit /etc/sysconfig/selinux, uncomment SELINUX= (remove the # from in front of SELINUX), set it to disabled and then reboot the server\n";
        }
    }
    elsif (`sestatus | grep "enabled"`) {
        print "${red}[FAIL] * SELINUX${NC}\n";
        print "\t \\_ Selinux is Enabled and is currently set to $selinuxmode\n";

        if (`sestatus | grep "Mode from config file:" | grep "disabled"`) {
            print "\t \\_ However Selinux is set to disabled in the config file. The server needs to be rebooted to apply the change\n";

        }
        else {
            if ( $fixit == 1 ) {
                print "\t \\_ To fix this edit /etc/sysconfig/selinux, set SELINUX= to disabled and then reboot the server\n";
            }
        }
    }

    elsif (`sestatus | grep "disabled"`) {
        print "${green}[PASS] * SELINUX${NC}\n";
        print "\t \\_ SELINUX appears to be disabled already\n";
    }

}

sub resolvechk {
    print "\n${UL}RESOLVER CHECK:${UE}\n";
    eval {
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm 3;
        $test = `curl google.com 2>/dev/null`;
        alarm 0;
    };

    my $nameserverchk = `awk '\$1 == "nameserver" { print \$2 }' /etc/resolv.conf 2>/dev/null`;

    if ( $nameserverchk eq "" || $@ ) {
        print "${yellow}[WARN] * Resolvers Look To Be Broken! Cannot proceed until fixed!${NC}\n";
        print "\t \\_ To fix this edit /etc/resolv.conf and verify you have working resolvers listed and they are not commented with #.\n";
        print "\t \\_ Examples of googles publicly working resolvers are below:\n";
        print "\t \\_ nameserver 8.8.8.8\n \t \\_ nameserver 8.8.4.4\n";
        exit 0;
    }
    else {
        print "${green}[PASS] * Resolvers Look To Be Working${NC}\n";
    }

}

sub yumgroupchk {
    print "\n${UL}YUM GROUP/PACKAGE CHECK:${UE}\n";

    my %bad_groups = (
        'FTP server'                  => 1,
        'Web Server'                  => 1,
        'X Window System'             => 1,
        'E-mail server'               => 1,
        'KDE Desktop'                 => 1,
        'Desktop'                     => 1,
        'Mail Server'                 => 1,
        'GNOME Desktop Environment'   => 1,
        'KDE (K Desktop Environment)' => 1,
        'Mono'                        => 1,
    );

    my @installed_bad;

    open( my $output, "-|", "yum grouplist 2>/dev/null" ) or die "Problem with yum! $1";

    my $print = 0;

    while (<$output>) {

        my $group = $_;
        $group =~ s/^\s+|\s+$//g;

        if ( $group =~ /Available Groups/ ) {
            $print = 0;
        }

        if ( $bad_groups{$group} ) {
            push( @installed_bad, $group ) if $print;
        }

        if ( $group =~ /Installed Groups/ ) {
            $print = 1;
        }
    }

    close $output;

    my $courier = `rpm -qa | grep -i courier`;
    if ( $courier || @installed_bad ) {
        if ($courier) {
            print "${red}[FAIL] * \"Courier E-mail Server\" Found${NC}\n";
            $failed = "yes";
        }
        if (@installed_bad) {
            foreach my $bad (@installed_bad) {
                print "${red}[FAIL] * \"$bad\" Group Found${NC}\n";
                $failed = "yes";
            }
        }
    }
    else {
        print "${green}[PASS] * No Yum Groups/Packages Need to Be Removed${NC}\n";
        $yumpass = "yes";
    }

    if ( $fixit == 1 ) {
        if ( !$yumpass ) {
            print "Would you like to fix this? Y or N: ";
            my $answer = <STDIN>;
            chomp($answer);
            if ( $answer =~ m/^y$|^yes$/i ) {
                foreach my $bad (@installed_bad) {
                    my $pid = open( my $out, "-|", "yum groupremove -y '$bad' 2>/dev/null" ) or die "Can't fork: $!";
                    if ($pid) {
                        waitpid $pid, 0;
                        close $out;
                    }
                    print "\t \\_ Yum Group $bad was removed.\n";
                }

                if ($courier) {
                    system("rpm -e --nodeps `rpm -qa | grep -i courier`");
                    if ( `rpm -qa | grep -i courier` eq "" ) {
                        print "\t \\_ Courier has been removed succesfully.\n";
                    }
                    else {
                        print "\t \\_ Courier does not appear to have been removed\n";
                    }

                }
            }
            else {
                foreach my $bad (@installed_bad) {
                    print "\t \\_ To remove \"$bad\" group manually run: yum groupremove \"$bad\"\n";
                }
                if ($courier) {
                    print "\t \\_ To remove Courier manually run: rpm -e --nodeps `rpm -qa | grep -i courier`${NC}\n";
                }
            }
        }
    }

}

sub hostnamechk {

    print "\n${UL}HOSTNAME CHECK:${UE}\n";
    chomp( my $hostname   = `hostname` );
    chomp( my $hostnameip = `curl -s -L http://cpanel.net/myip 2>/dev/null` );
    chomp( my $fqdnhost   = `hostname | grep -P '[a-zA-Z0-9-]+[.]+[a-zA-Z0-9-]+[.]+[a-zA-Z0-9]+'` );

    if ( $hostname eq $fqdnhost ) {
        print "${green}[PASS] * The server's hostname of $hostname is a FQDN${NC}\n";
        $hostpass = "yes";
    }
    else {
        print "${red}[FAIL] * The server's hostname of $hostname is not a FQDN${NC}\n";
        $failed = "yes";
    }

    if ( $fixit == 1 ) {
        if ( !$hostpass ) {
            chomp( my $oldhostname = `hostname` );
            print "Would you like to fix this? Y or N: ";
            my $answer = <STDIN>;
            chomp($answer);
            if ( $answer =~ m/^y$|^yes$/i ) {
                my $hostnamefile = '/etc/sysconfig/network';
                print "Enter new hostname\n";
                print "\t \\_ For example a FQDN should look like server.domain.com or server.domain.co.uk\n";
                my $newhostname = <STDIN>;
                chomp($newhostname);

                if ( $rhel5 || $rhel6 ) {

                    system("hostname $newhostname");
                    my $hostsource = '/etc/sysconfig/network';
                    my $hosttemp   = '/etc/sysconfig/network.new';
                    chomp( my $date = `date +%Y-%m-%d-%H:%M:%S` );
                    my $hostbak = '/etc/sysconfig/network.bak.' . $date;

                    $hostfound = 0;
                    $addhost   = '$newhostname';

                    open( HOSTSOURCE, '<', $hostsource ) or die "cannot open $source";
                    open( HOSTTEMP,   '>', $hosttemp )   or die "cannot open $dest";

                    while (<HOSTSOURCE>) {
                        s/HOSTNAME=\S*/HOSTNAME=$newhostname/g;
                        print HOSTTEMP $_;

                    }

                    close HOSTSOURCE;
                    close HOSTTEMP;

                    rename $hostsource => $hostbak;
                    rename $hosttemp   => $hostsource;
                    chomp( my $hostname   = `hostname` );
                    chomp( my $hostconfig = `awk '/HOSTNAME=/' /etc/sysconfig/network` );
                    my $curhost = "HOSTNAME=$newhostname";

                    if ( $hostconfig eq $curhost && $hostname eq $newhostname ) {
                        print "\t \\_ Hostname was succesfully changed from $oldhostname to $newhostname\n";
                    }

                }

                elsif ($rhel7) {
                    system("hostnamectl set-hostname $newhostname");
                    print "\t \\_ Hostname was succesfully changed from $oldhostname to $newhostname\n";
                }

                else {
                    print "\t \\_ The hostname does not appear to have been changed succesfully\n";
                    print "\t \\_ To manually fix this run: hostnamectl set-hostname newhostname.domain.com\n";
                    print "\t \\_ For example a FQDN should look like server.domain.com or server.domain.co.uk\n";
                }
            }
            else {
                print "\t \\_ To manually fix this run: hostnamectl set-hostname newhostname.domain.com\n";
                print "\t \\_ For example a FQDN should look like server.domain.com or server.domain.co.uk\n";
            }
        }
    }

    if (`dig`) {
        chomp( my $hostname  = `hostname` );
        chomp( my $digresult = `dig $hostname +short` );
        if ( $digresult eq $hostnameip ) {
            print "${green}[PASS] * The IP the hostname resolves to is the same as what's set on the server${NC}\n";
            $digpass = "yes";
        }
        elsif ( $digresult eq "" ) {
            print "${yellow}[WARN] * The hostname on the server does not resolve to an IP address${NC}\n";
            if ( $fixit == 1 ) {
                print "\t \\_ To fix this add an A record to DNS for the hostname and point it to the servers primary IP $hostnameip\n";
            }
        }
        else {
            print "${yellow}[WARN] * The hostname resolves to a different IP than what's set on the server${NC}\n";
            print "\t \\_ The hostname should resolve to $hostnameip, but actually resolves to $digresult${NC}\n";
            if ( $fixit == 1 ) {
                print "\t \\_ To fix this edit the A record in DNS for the hostname and point it to this servers primary IP $hostnameip\n";
            }
        }

    }
    else {
        print "${yellow}[WARN] * Can't check if hostname resolves to an IP because Dig is not installed.${NC}\n";
        $failed = "yes";
        if ( $fixit == 1 ) {
            if ( !$digpass ) {
                print "Would you like to fix this? Y or N: ";
                my $answer = <STDIN>;
                chomp($answer);
                if ( $answer =~ m/^y$|^yes$/i ) {
                    system("yum -y install bind-utils > /dev/null");
                    if (`dig`) {
                        print "\t \\_ dig was installed succesfully\n";
                    }
                    else {
                        print "\t \\_ dig does not appear to have been installed succesfully. Try a manual install\n";
                        print "\t \\_ To manually install dig run: yum install bind-utils\n";
                    }
                    chomp( my $hostname  = `hostname` );
                    chomp( my $digresult = `dig $hostname +short` );
                    if ( $digresult eq $hostnameip ) {
                        print "${green}[PASS] * The IP the hostname resolves to is the same as what's set on the server${NC}\n";
                        $digpass = "yes";
                    }
                    elsif ( $digresult eq "" ) {
                        print "${yellow}[WARN] * The hostname on the server does not resolve to an IP address${NC}\n";
                        print "\t \\_ To fix this add an A record to DNS for the hostname and point it to the servers primary IP $hostnameip\n";
                    }
                    else {
                        print "${yellow}[WARN] * The hostname resolves to a different IP than what's set on the server${NC}\n";
                        print "\t \\_ The hostname should resolve to $hostnameip, but actually resolves to $digresult${NC}\n";
                        print "\t \\_ To fix this edit the A record in DNS for the hostname and point it to this servers primary IP $hostnameip\n";
                    }
                }
                else {
                    print "\t \\_ To manually install dig run: yum install bind-utils\n";
                }
            }
        }
    }
}

sub oskernelchk {
    print "\n${UL}OS & KERNEL CHECKS:${UE}\n";
    if ( $rhel6 || $rhel5 ) {
        print "${green}[PASS] * The OS is Supported${NC}\n";
        print "\t \\_ $rhel\n";
    }
    elsif ($rhel7) {
        print "${green}[PASS] * The OS is Supported${NC}\n";
        print "\t \\_ $rhel7prnt\n";
    }
    elsif ($amazon) {
        print "${green}[PASS] * The OS is Supported${NC}\n";
        print "\t \\_ Amazon Linux\n";
    }
    else {
        print "${red}[FAIL] * The OS is Not Supported${NC}\n";
    }

    chomp( my $runlevel = `runlevel | awk '{print \$2}'` );
    if ( $runlevel eq 3 ) {
        print "${green}[PASS] * OS Run Level is 3${NC}\n";
    }
    else {
        print "${red}[FAIL] * OS Run Level is $runlevel${NC}\n";
        if ( $fixit == 1 ) {
            print "\t \\_ To fix this run: init 3\n";
        }
    }

    chomp( my $tmp = `stat -c "%a %n" /tmp | awk '{print \$1}'` );
    if ( $tmp eq 1777 ) {
        print "${green}[PASS] * /tmp is set to 1777 permissions${NC}\n";
    }
    else {
        print "${red}[FAIL] * /tmp is set to $tmp${NC}\n";
        if ( $fixit == 1 ) {
            print "\t \\_ To fix this run: chmod 1777 /tmp\n";
        }
    }

    chomp( my $mem = `awk '/MemTotal/ { print \$2 }' /proc/meminfo` );
    if ( $mem > 524288 ) {
        print "${green}[PASS] * System Memory Higher than 512MB${NC}\n";
    }
    else {
        print "${red}[FAIL] * System Memory Lower than 512MB${NC}\n";
        print "Please install at least 512MB to 1GB of Memory before using cPanel\n";
    }

    #change warning messages
    chomp( my $uname = `uname -r` );
    if (`uname -r | grep "grs"`) {
        print "${yellow}[WARN] * Kernel Not Supported${NC}\n";
        print "\t \\_ GRSEC Kernels are Not Supported. If you have issues installing cPanel please switch to the stock kernel and try re-installing.\n";
        print "\t \\_ $uname\n";
    }
    elsif (`uname -r | grep -i "xx"`) {
        print "${yellow}[WARN] * Kernel Not Supported${NC}\n";
        print "\t \\_ GRSEC Kernels are Not Supported. If you have issues installing cPanel please switch to the stock kernel and try re-installing.\n";
        print "\t \\_ $uname\n";
    }
    elsif (`uname -r | grep -P "2.[0-9]."`) {
        print "${green}[PASS] * Kernel Supported${NC}\n";
        print "\t \\_ $uname\n";
    }
    elsif ($rhel7) {
        if (`uname -r | grep -P "3.[0-9]."`) {
            print "${green}[PASS] * Kernel Supported as we are running $rhel7prnt${NC}\n";
            print "\t \\_ $uname\n";
        }
    }
    elsif ($amazon) {
        if (`uname -r | grep -P "4.[0-9]."`) {
            print "${green}[PASS] * Kernel Supported as we are running Amazon Linux${NC}\n";
            print "\t \\_ $uname\n";
        }
    }
    else {
        print "${yellow}[WARN] * Kernel Not Supported. If you have issues installing cPanel please switch to the stock kernel and try re-installing.${NC}\n";
        print "\t \\_ $uname\n";
    }

    print "${yellow}[INFO] * Verify System has enough Disk Space to install cPanel. You should have at least 6GB of space in / or /usr${NC}\n";
    my $dflines = `df -h`;

    foreach $line ( split /\n/, $dflines ) {
        print "\t \\_ $line\n";
    }
}
