# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
define apache2::vhost($port, $docroot, $ssl, $template='apache2/default_vhost.erb', $priority, $serveraliases = '' ) {
	case $operatingsystem {
		"ubuntu","debian": {
			$webconfdir = "/etc/apache2/sites-enabled"
		}
		default: {
			$webconfdir = "/etc/httpd/conf.d"
		}
	}

	file {
		"${webconfdir}/${priority}-${name}.conf":
		content => template($template),
	}
}
