#!/bin/bash
REDTEXT='\e[0;31m'
NORMTEXT='\e[0m'
PUPPETMASTER='<%= scope.lookupvar('tfound::puppetmasterip') %>'
PUPPETMASTERNAME='<%= scope.lookupvar('tfound::puppetmaster') %>'

function msg()
{
	echo -e " * ${REDTEXT} $* ${NORMTEXT}"
}
function install_puppet()
{
	msg Setting up puppet ...
        cat > /etc/yum.repos.d/puppetlabs.repo <<EOM
[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/6/products/x86_64/
enabled=0
gpgcheck=0

[puppetlabs2]
name=Puppet Labs Packages Deps
baseurl=http://yum.puppetlabs.com/el/6/dependencies/x86_64/
enabled=0
gpgcheck=0
EOM
        yum -y --enablerepo=puppetlabs,puppetlabs2 install puppet-2.7.19-1.el6.noarch 
	yum -y install redhat-lsb
	[ -e /etc/puppet/puppet.conf ] && cp /etc/puppet/puppet.conf /etc/puppet/puppet.conf.default
	#lsbdist=$(head -1 /etc/issue)
	#lsbdistmaj=$(head -1 /etc/issue | awk '{print $3'}|cut -f1 -d.)
	cat > /etc/puppet/puppet.conf <<EOK
[main]
        vardir = /var/lib/puppet
        logdir = /var/log/puppet
        rundir = /var/run/puppet
        ssldir = \$vardir/ssl
        server = <%= scope.lookupvar('tfound::puppetmaster') %>
        pluginsync = true
        factpath = \$vardir/lib/facter

[agent]
        classfile = \$vardir/classes.txt
        localconfig = \$vardir/localconfig
        report = true
        runinterval = 3600
EOK
	echo "<%= scope.lookupvar('tfound::puppetmasterip') %>	<%= scope.lookupvar('tfound::puppetmaster') %>" >> /etc/hosts
	cat > /root/puppetup.sh <<PUPP
#!/bin/bash
rm -f /var/lib/puppet/lib/puppet/provider/zenoss.rb >/dev/null 2>&1
puppetd -t --waitforcert 10
PUPP
	chmod +x /root/puppetup.sh
	mkdir -p /etc/facter/facts.d
	echo "datacenter=atl" >> /etc/facter/facts.d/vars.txt
	echo "nodeless_zenoss=client" >> /etc/facter/facts.d/vars.txt
}

function config_auth()
{
	msg Setting AD authentication ...
	[ -e /etc/ldap.conf ] && cp /etc/ldap.conf /etc/ldap.conf.default
	[ -e /etc/pam.d/sshd ] && cp /etc/pam.d/sshd /etc/pam.d/sshd.default
	cat > /etc/pam.d/sshd <<EOZ
#%PAM-1.0
auth       include      system-auth
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
session    optional     pam_keyinit.so force revoke
session    include      system-auth
session    required     pam_loginuid.so
# Create home directory for AD user
session    required pam_mkhomedir.so skel=/etc/skel/ umask=0077
EOZ

}
function config_sshkeys()
{
  	msg Adding in key. puppet should take care of this ...
	mkdir -p  /mnt/sysimage/root/.ssh
	cat > /root/.ssh/authorized_keys <<EOD
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuUCCM7vvbRVGJFCG34PGi9tZMgSjR4NhGPsxXi0w+ec2yKsY6Yx+xlSMJYMLEKsHvpWetDqfRXkMv3Of0NsIUFJqADovL3TnVkpdiwDcrCWMpu9G0fTAUul5rUbV4mjk+pK82Pk07XHL8wlDuQmOvHTj22ICYmBsTBPcVRnWYmSCjhtRxgPISSVzFC+ylm4jOTZaDfRw2lxu2R2xUWLViMx3HdAIm7rqcKSdZ4wCmUwsbVxvHw1KewxZ1urwXiBO/2dSqCD6gdO6fCkHIf7d4gbpyCtM7wW2G3IasgrjiUzImCBVLbP4FASqsLmgjABk8CdrupJZh/gKcETGqpv2Aw== root@intvajo01
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+fZTPCtWzTYfE1WRiUZrqgzYipIc1ODc19HfZfmWq525DEQoAuvObdNfrWq4Nii6L3gHFRGAIo7SIsmI8Q0hek0frIBBrO/aEXBcRUCZgJA6VVQSP1oquiGCm39c+i0DWIFEARrXgjMnDd5BWWF0my0Vh+rH2KvvDNX+EtXEmWZrX7DzluM4lj6mZCYmxwMAFJh4v+ENMkI91Cnob6gmS9ge+aF1sQF9IHd/ZQlPNvsNk9t5HClM+hFEAQTyj0DqjYm7sgIbxM9trdckaL+/MG3hcB7MdshorvhBei6IAV3Tf4SUx8VghAzeFxDTFk4PzXSmJgHt693qjG8lJak8/
EOD
	chmod 700  /root/.ssh
	chmod 600  /root/.ssh/authorized_keys

}
function config_network()
{
	dialog --title "Configure eth0 Network"  --yesno "Configure Hostname, eth0 IP and DNS? Tab to No." 6 25

	if [ $? -eq 0 ]
	then

		dialog --title "Set Hostname - $(hostname)" --backtitle "Post Install Configuration" --inputbox "Gimme FQDN Hostname: " 8 60 2> tmphostname ; host=$(<tmphostname) && rm -f tmphostname
		ipaddress=$(ifconfig eth0| grep "inet a" | awk '{print $2}' |cut -f2 -d:)
		dialog --title "Static IP address - ${ipaddress}"  --backtitle "Post Install Configuration" --inputbox "Gimme IP: " 8 60 2> tmpipaddress ; 
		ipaddress=$(<tmpipaddress) && rm -f tmpipaddress

		netmask=$(ifconfig eth0| grep "inet a" | awk '{print $4}' |cut -f2 -d:)
		dialog --title "Netmask - ${netmask}"  --backtitle "Post Install Configuration" --inputbox "Gimme Netmask: " 8 60 2> tmpnm ; 
		netmask=$(<tmpnm) && rm -f tmpnm

		gw=$(route | grep default | awk '{print $2}' )
		dialog --title "Gateway - ${gw}"  --backtitle "Post Install Configuration" --inputbox "Gimme Gateway: " 8 60 2> tmpgw ; 
		gw=$(<tmpgw) && rm -f tmpgw

		dns1=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ' | awk '{print $1}')
		dialog --title "1st DNS Server - ${dns1}" --backtitle "Post Install Configuration" --inputbox "Gimme DNS: " 8 60 2> tmpdns1 ; 
		dns1=$(<tmpdns1) && rm -f tmpdns1
		
		dns2=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ' | awk '{print $2}')
		dialog --title "2nd DNS Server - ${dns2}" --backtitle "Post Install Configuration" --inputbox "Gimme DNS: " 8 60  2> tmpdns2 ; 
		dns2=$(<tmpdns2) && rm -f tmpdns2

		[ -e /etc/sysconfig/network ] && cp -f /etc/sysconfig/network.default
		cat > /etc/sysconfig/network <<EOG
# Configured by Tfound Post Install Script
NETWORKING=yes
NETWORKING_IPV6=no
HOSTNAME=$host
GATEWAY=$gw
EOG
		[ -e /etc/sysconfig/network-scripts/ifcfg-eth0 ] && cp -f /etc/sysconfig/network-scripts/ifcfg-eth0.default
		cat > /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOH
# Configured by Tfound Post Install Script
DEVICE=eth0
BOOTPROTO=static
IPADDR=$ipaddress
NETMASK=$netmask
GATEWAY=$gw
ONBOOT=yes
EOH
		[ -e /etc/resolv.conf ] && cp -f /etc/resolv.conf /etc/resolv.postconfig
                cat > /etc/resolv.conf <<EOJ
# Configured by Tfound Post Install Script
domain tfound.org
search tfound.org
nameserver $dns1
nameserver $dns2
EOJ

	fi
}
date
echo '**************************************'
echo '*               TFOUND               *'
echo '*               init.sh              *'
echo '**************************************'

install_puppet
#config_auth
#config_sshkeys
#config_network

echo '**************************************'
echo '*                Done!               *'
echo '**************************************'
date




