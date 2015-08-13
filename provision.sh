#!/bin/sh

##################################################################
##| this provision script will install necessary packages       |#
##| and configure services for a LAMP development environment   |#
##| in a Vagrant Cent0S 5.11 Box for PHP 5.1                    |# 
##################################################################

# Set variables for your username and password:
username=rubens
password=1234

# Set up shell script for installing everything needed for the box:
echo "**** Starting provision script! ****"
echo "Updating and installing packages..."
yum update -y
yum install -y epel-release     
yum install -y  vim-enhanced awk git wget url gcc htop tree unzip dkms net-tools arpwatch nmap bind-utils mlocate httpd mysql-server ntp nfs-utils portmap

# Uncomment this for php based apps:
yum install -y php && sudo yum install -y php-pear  
yum install -y php-pecl-apc php-pecl-imagick php-pecl-json php-pecl-memcache php-pecl-memcached php-pecl-xdebug  php-pecl-zip


echo "Adding hostname and IP to hosts file..."
# Set hostname for the machine and add the entry in /etc/hosts file:
echo "192.168.50.123  centos5.home.local centos5" >> /etc/hosts

echo "Setting european ntp servers..."
# Change centos ntp servers by european ones on ntp.conf: 
sed -i 's/centos/europe/g' /etc/ntp.conf
service ntpd start

echo "Setting default language..."
# Set language for users:
echo "export LANG=en_US.UTF-8" >> /home/vagrant/.bashrc
echo "export LANG=en_US.UTF-8" >> /home/$user/.bashrc

echo "Making services persistent after reboots, and stating services..."
# Make services persistent through boot:
chkconfig httpd on
chkconfig mysqld on
chkconfig sshd on
chkconfig portmap on


echo "Creating user, password and editing sudoers file"
# Create user rubens: 
useradd -m -G wheel -s /bin/bash $username
# Set user password:
echo $password | passwd $username --stdin
#add the wheel group and the user to sudoers:
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "$username ALL=(ALL:ALL) ALL" >> /etc/sudoers
# Allow user rubens ssh to machine:
echo "AllowUsers $username" >> /etc/ssh/sshd_config

echo "Creating .bash_profile and setting permissions..."
# Create .bash_profile for user rubens:
cat <<\EOF >> /home/$username/.bash_profile
# Prompt settings:
#=================

export CLICOLOR=1
export PS1="\[$(tput setaf 2)\]\u\[$(tput setaf 2)\]@\h\[$(tput setaf 4)\] \W\[$(tput setaf 2)\]\\$ \[$(tput sgr0)\]"


# Grep and Ls color settings:
#============================

export GREP_OPTIONS='--color=auto'       # Tell grep to highlight matches
export LSCOLORS=ExFxBxDxCxegedabagacad   # Ls colors


# Common use Aliases:
#====================

# if user is not root, pass all commands via sudo: 
if [ $UID -ne 0 ]; then
    alias reboot='sudo reboot'
    alias poweroff='sudo poweroff'
    alias upgradeb='sudo apt-get update && sudo apt-get -y upgrade'   # Upgrade Debian based distros
    alias upgraderel='sudo yum -y update'                             # Upgrade RHEL based distros without removing obsolete 
fi
alias ghome='cd ~/Desktop'
alias getc='cd /etc'
alias goutput='cd /var/log'
alias gtmp='cd /tmp'
alias gdocs='cd ~/Documents'
alias c='clear'
alias vi='vim'


# Ls Aliases:
#============
 
alias l='ls -lAh'   # List files in human readable format with color and without directories    
alias ld='ls -hog'      # The ls Hog - easy to remember directory listing
alias lx='ls -lXB'      #  Sort by extension.
alias lk='ls -lSr'      #  Sort by size, biggest last.
alias lt='ls -ltr'      #  Sort by date, most recent last.
alias lc='ls -ltc'      #  Sort by/show change time,most recent first.
alias lu='ls -ltu'      #  Sort by/show access time,most recent first.

# Network aliases:
#=================

alias pubip='curl ip.appspot.com'           # My public IP address
alias netlisten='lsof -i -P | grep LISTEN'  # Find active network listeners
alias pingle='ping google.com'              # Ping google.com
alias speedtest='wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip'  # Network Speedtest
#Query all DNS records in a domain:
digdomain() {
    dig -tAXFR $1
}


# Other aliases:
#================

alias passwdgen='dd if=/dev/random bs=16 count=1 2>/dev/null | base64 | sed 's/=//g''   # passwd generator
#Yet another Password generator. You can change the last number to your needs: 
alias genpass='openssl rand -base64 9'
alias ltree='tree -C | less -R'              # Tree current dir with colors
alias memhog='ps -o time,ppid,pid,nice,pcpu,pmem,user,comm -A | sort -n -k 6 | tail -15'  # Whats eating your memory
alias sar5='sar 1 5'                         # First five consuming processes
alias df='df -h'                             # Disk space usage in human readable form
alias ..='cd ..'                             # Upper parent directory
alias ...='cd ../../'                        # Two upper parent directory
alias big='du -ks *| sort -n'                # Find the biggest in a folder
alias big10='du -cks *|sort -rn|head -11'    # list top ten largest files/directories in current dir
alias msg='wall'                             # Broadcast message to all users

# Find Aliases:
#==============

alias qfind="find . -name "                 # qfind:    Quickly search for file
ff () { /usr/bin/find . -name "$@" ; }      # ff:       Find file under the current directory
ffs () { /usr/bin/find . -name "$@"'*' ; }  # ffs:      Find file whose name starts with a given string
ffe () { /usr/bin/find . -name '*'"$@" ; }  # ffe:      Find file whose name ends with a given string


# Extract most Known archives:
#==============================

extract () {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}


# Git load file:
#===============

if [ -f ~/.git-completion.bash ]; then
source ~/.git-completion.bash
fi

PATH=$PATH:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
export PATH
EOF
chown $username:$username /home/$username/.bash_profile
chmod 644 /home/$username/.bash_profile
su - $username -c "source /home/$username/.bash_profile"


echo "Setting PATH and sourcing files..."
# Set $PATH for all users, and source the files:
cat <<\EOF >> /etc/environment
PATH=$PATH:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
export PATH
EOF

cat <<\EOF >> /etc/profile
PATH=$PATH:/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
export PATH
EOF
source /etc/environment
source /etc/profile

echo "Creating .ssh dir and creating public key..."
# Make .ssh dir and copy your public key to authorized_keys file:
mkdir -p /home/$username/.ssh
cat <<EOF > /home/$username/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAoCQx2Qfx6URtvRF2PvURa9jXU1MaNiLYD56V7cXObJ4tiCMomaK3ZytfYgM1enz+evQB0qhLQCA37GfjqfT1iHtC7PGsHaWF7yF04roVDM/VRIl5eZYrAkIpLmqRN/hfNo3wxgnJq/RzhiFfvhrV0QKB8+ysvC3Y1RzeCdYFWL3RxZQjO/iCrSdoU9SpBmArvBYP2LuwJs5hd0EL8LtxzaDZKKv/TqVdWUiPbl5LiIWz16iZuVBuShEm3otBmc5faop/wySmHSb0pMONVfysGHoMzrNa8bRlqv/616DYLPpNT/QOKxvq4nHrnh7vtI9S6a/+2KyX53xJYFNOnrzxyQ== vagrant@centos5.home.local
EOF
chown -R $username:$username /home/$username/.ssh/
chmod 0700 /home/$username/.ssh

echo "Creating document root..."
# Make project.dev root dir if vagrant doesn't create it at start:
if [ -d /var/www/html/project.dev ]; then
 echo "Dir project.dev already exists "
else
    mkdir -p /var/www/html/project.dev 
fi

echo "Creating phpinfo.php file on document root..."
# Create dummy index.html page on project.dev root:
cat <<EOF > /var/www/html/project.dev/index.php
<?php
    echo "<h1>Apache It's working!<h1>";
    echo "\n";
?>
EOF
# Add index.php to DirectoryIndex:
sed -i 's/DirectoryIndex index.*/DirectoryIndex index.html index.html.var index.php/' /etc/httpd/conf/httpd.conf
# Mount vbox shared folder with correct permissions:
#mount -t vboxsf -o uid=`id -u apache`,gid=`id -g apache`,dmode=777 var_www_project.dev /var/www/html/project.dev
echo "Setting permissions and ownership to document root"
# just in case, fix permissions and ownership:
chown -R apache:apache /var/www/html/project.dev
chmod -R 775 /var/www/html/*

echo "Configuring vhost..."
echo "Include vhost.d/*.conf" >> /etc/httpd/conf/httpd.conf
mkdir /etc/httpd/vhost.d/
# Set the vhost for the project:
cat <<EOF >> /etc/httpd/vhost.d/project.dev.conf
<VirtualHost *:80>
       ServerName project.dev
       ServerAlias www.project.dev
       DocumentRoot /var/www/html/project.dev
       <Directory /var/www/html/project.dev>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
        </Directory>

CustomLog /var/log/httpd/project.dev-access.log combined
ErrorLog /var/log/httpd/project.dev-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
</VirtualHost>

 #=====================
 # HTTPS CONFIGURATION:
 #=====================

#<VirtualHost _default_:443>
#        ServerName project.dev
#        DocumentRoot /var/www/html/project.dev
#        <Directory /var/www/html/project.dev>
#                Options Indexes FollowSymLinks MultiViews
#                AllowOverride All
#        </Directory>

#        CustomLog /var/log/httpd/project.dev-ssl-access.log combined
#        ErrorLog /var/log/httpd/project.dev-ssl-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
#        LogLevel warn

#        SSLEngine on
#        SSLCertificateFile    /etc/ssl/certs/project.dev.crt
#        SSLCertificateKeyFile /etc/ssl/certs/project.dev.key

#</VirtualHost>
EOF

# Restart Apache web server:
echo "Start Apache web server..."
service httpd start 


# Edit my.cnf MyQSL file:
echo "Editing mysql my.cnf file..."
if [ -f /etc/my.cnf ]; then
cat <<EOF > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Default to using old password format for compatibility with mysql 3.x
# clients (those using the mysqlclient10 compatibility package).
old_passwords=1
bind-address=0.0.0.0
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
# symbolic-links=0

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
service mysqld start
else
echo "MySQL not installed or my.cnf file is missing"
fi


# Notice the script end:
echo "**** Done with the provision script! ****"
