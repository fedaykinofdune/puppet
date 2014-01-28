# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class sudo {
		package { 'sudo':
			ensure => installed, # ensure sudo package installed
	}

		augeas { 'sudodtaylor':
    			context => '/files/etc/sudoers', # target file is /etc/sudoers
    			changes => [
        			'set spec[user = "%dtaylor"]/user %dtaylor',
        			'set spec[user = "%dtaylor"]/host_group/host ALL',
        			'set spec[user = "%dtaylor"]/host_group/command ALL',
        			'set spec[user = "%dtaylor"]/host_group/command/runas_user ALL',
        			'set spec[user = "%dtaylor"]/host_group/command/tag NOPASSWD',
    				]
			}
}
