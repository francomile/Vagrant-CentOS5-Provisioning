# Vagrant-CentOS5-Provisioning
---
###Vagrant CentOS 5 Provision script for LAMP server
This is a CentOS 5.11 LAMP environment for development in PHP 5.1, for some kind of obsolete needs...


###Installation:
Install [Vagrant](https://www.vagrantup.com/).  
Install [Virtualbox](https://www.virtualbox.org/).     
Clone the project: `git clone git@github.com:francomile/Vagrant-CentOS5-Provisioning.git`    
Tweak the **provision.sh** script to fit your needs: assign your $user,$password and areplace public ssh key by your own.
In a terminal `cd` into the project folder and run `vagrant up`.    
Get a cup of cofee and let the provision script do the stuff...
When done, run `vagrant ssh` or `ssh $user@192.168.50.123` for accessing the virtual machine with your own user.
Edit your hosts file and add the line `192.168.50.123  project.dev`.    
Open the browser at [http://project.dev](http://project.dev) and confirm it's working.

	
 