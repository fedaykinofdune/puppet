# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class ntp {
	$package = "ntp"
	case $operatingsystem {
		"ubuntu","debian": {
			$service = "ntp"
			file {
				"/etc/default/ntp":
					require => Package[$package],
					source  => [ "puppet:///modules/ntp/ntp.default" ],
					notify  => Exec["service $service restart"]
					;
			}
		}
		default: {
			$service = "ntpd"

			file {
				"/etc/sysconfig/ntpd":
					require => Package[$package],
					source  => [ "puppet:///modules/ntp/ntp.sysconfig" ],
					notify  => Exec["service $service restart"]
					;
			}
		}
	}

	package { $package: ensure => installed; }
	service { $service: enable => true; }

	file {
        "/etc/ntp.conf":
                require => Package["ntp"],
                source  => [ "puppet:///modules/ntp/ntp.conf" ],
                notify  => Exec["service $service restart"]
                ;
	"/var/run/ntp/":
		ensure  => directory,
		owner   => ntp,
		group   => ntp,
		require => Package[$package],
		mode    => 755
		;
	"/var/lib/ntp/":
		ensure  => directory,
		owner   => ntp,
		group   => ntp,
		require => Package[$package],
		mode    => 755
		;
	"/var/log/ntp/":
		ensure  => directory,
		owner   => ntp,
		group   => ntp,
		require => Package[$package],
		mode    => 755
		;
	"/etc/logrotate.d/ntpd":
		require => Package[$package],
		source  => [ "puppet:///modules/ntp/ntp.logrotate" ]
		;
	}

	exec { "service $service restart":
		refreshonly => true,
	}
}
