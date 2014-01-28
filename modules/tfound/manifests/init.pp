# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class tfound (  $puppetmasterip = '10.55.3.111', $puppetmaster = 'config-mgr.maskedadmins.com') {
    if 'config-mgr' in $fqdn {
	$repoip='10.55.3.111'
        #service { "puppet-dashboard": ensure => running, enable => true; }
        #service { "puppet-dashboard-workers": ensure => running, enable => true; }
        host { "$fqdn": ip => "$ipaddress"; }
    } else {
	$repoip=$puppetmasterip
	host { "$puppetmaster":
            ip => "$puppetmasterip",
            host_aliases => 'puppet',
    	}
    }
$env = $environment ? {
    /(?i-mx:development)/   => 'dev',
     /(?i-mx:qa)/            => 'qa',
    /(?i-mx:production)/    => 'prod',
    /(?i-mx:stage)/         => 'stage',
    default                 => 'dev'
    }
                                                        
        case $operatingsystem {
                "ubuntu","debian": {
                        service { "puppet": ensure => stopped, enable => false; }
                        package {
                                "logcheck": ensure => purged;
                                "mpt-status": ensure => purged;
                        }
                        file {
                                "/etc/default/puppet":
                                        source => [ "puppet:///modules/tfound/puppet.default" ];
                        }
                }
		"Fedora": {
                        package {
                                "logwatch": ensure => absent;
                                "yum-utils": ensure => installed;
                                "vim-enhanced": ensure => installed;
                                "screen":       ensure => installed;
                                "mc":           ensure => installed;
                                "telnet":           ensure => installed;
                                "python-boto":  ensure => installed;
                                "fortune-mod":  ensure  => installed;
                                "sysstat":  ensure  => installed;
                        }
			service {
				            "cups": ensure => stopped, enable => false;
				            "cpuspeed": enable => false;
				            "iptables": enable => false;
				            "ip6tables": enable => false;
                                            "puppet": ensure => stopped, enable => false;
			}
	            	file {
                                "/etc/yum.repos.d/tfound.repo":
                                        content  => template("tfound/tfound.repo.erb"),
                                ;
                                "/etc/yum.conf":
                                        content => template("tfound/yum.conf.erb"),
                                ;
                        }
 		
		}
                "Windows": { 
                                include tfound::windows
                }
                default: {
                        package {
                                "logwatch": ensure => absent;
                                "yum-utils": ensure => installed;
                                "vim-enhanced": ensure => installed;
                                "epel-release": ensure => installed;
                                "puppetlabs-release":   ensure => installed;
                                #"screen":       ensure => installed;
                                "mc":           ensure => installed;
                                "telnet":           ensure => installed;
                                "python-boto":  ensure => installed;
                                "fortune-mod":  ensure  => installed;
                                "sysstat":  ensure  => installed;
                        }
			            service {
				            "cups": ensure => stopped, enable => false;
				            "cpuspeed": enable => false;
				            "iptables": enable => false;
				            "ip6tables": enable => false;
			            }
                        case $lsbmajdistrelease {
                                "6": {
                                        package {
                                                "yum-plugin-downloadonly": ensure => installed;
                                                "redhat-lsb": ensure => installed;
                                        }
                                }
                                default: {
                                        package {
                                                "yum-downloadonly": ensure => installed;
                                        }
                                }
                        }
			            file {
                                "/etc/yum.repos.d/tfound.repo":
                                        content  => template("tfound/tfound.repo.erb"),
                                ;
                                "/etc/yum.conf":
                                        content => template("tfound/yum.conf.erb"),
                                ;
                        }
                }
        }
  if $operatingsystem != "Windows" {
    file { "/etc/cron.d/puppet.cron":
        content => template("tfound/puppet.cron"),
        ;
    }
        file {"/etc/logrotate.d/syslog":
                path => "/etc/logrotate.d/syslog",
                source => "puppet:///modules/tfound/syslog.logrotate",
                replace => true,
                owner => root,
                group => root,
                mode => 644,
        }
        if $datacenter == "ec2" {
        file { "/etc/resolv.conf":
            content =>  template("tfound/ec2-resolv.conf.erb")
        }
    }
        file { "/etc/puppet/puppet.conf":
			    content => template("tfound/puppet.erb")
                ;
                "/usr/local/tfound":
                ensure  => directory,
                ;
		        "/etc/profile.d/history.sh":
			    source  => [ "puppet:///modules/tfound/history.sh" ],
			    mode    => 755
		        ;
	    }  

	ssh_authorized_key { 
			"root@maskedadmins.com":
			ensure => "present",
			type => "ssh-rsa",
			key => "AAAAB3NzaC1yc2EAAAABIwAAAQEAnBlcXUd9fJtvocP4O2qkc7kfgYzeJMdQs4YasP1U5JPXPKToHYCGYv8VcheIODlnxI3FjI4AR7G5naH+yw8Ahr1Rgstltr804p/Fh50ict8Lelps0QdaHFW5pGzHjjf9wMBf+juMT950l3Qzg7c/GApXMaigZv9WvhWFwNBnhV6uy6fHCsoU/sb13ld+6uxYleLpA9vfIkV+hI3uMeKRQJ1uvHyGRFqfuVNHcMv1ywvKIRegRhs9l3F9VNnXEKZlJfJExDN+tB+fdjYhGZCVgDE/NnAv5ZLruyVsKZFzH12D8Rd6GJuXmw8zKv9bm3syZI7RlMUtvDp4R/2El+nTnQ==",
			user => "root",
			}
    file { "/etc/setprompt.sh":
        content => template("tfound/setprompt.erb"),
        mode => 755
        ;
        "/etc/bashrc":
        content => template("tfound/bashrc"),
        mode => 644
        ;
        "/root/.screenrc":
        content => template("tfound/screenrc"),
        mode => 644
        ;
	"/root/.ssh":
	ensure	=> directory,
	mode	=> 700
	;
        "/root/.ssh/config":
        content => template("tfound/sshconfig"),
        mode => 600,
	require => File['/root/.ssh']
        ;
        "/root/.ssh/tfound-ec2.pem":
        content => template("tfound/tfound-ec2.pem"),
        mode => 600,
	require => File['/root/.ssh']
        ;
        "/root/.ssh/id_rsa":
        content => template("tfound/id_rsa"),
        mode => 600,
	require => File['/root/.ssh']
        ;
        "/root/.ssh/id_rsa.pub":
        content => template("tfound/id_rsa.pub"),
        mode => 600,
	require => File['/root/.ssh']
        ;
        "/root/.ssh/dtaylor-openstack.priv":
        content => template("tfound/dtaylor-openstack.priv"),
        mode => 600,
	require => File['/root/.ssh']
        ;
        "/opt/tfound":
        ensure  => directory
        ;
        "/opt/tfound/bin":
        ensure  => directory,
        require => File["/opt/tfound"]
        ;
        "/opt/tfound/bin/tfound-manage-puppet.sh":
        content => template("kickstart/tfound-manage-puppet.sh"),
        mode => 755
        ;
    }
  }
}
