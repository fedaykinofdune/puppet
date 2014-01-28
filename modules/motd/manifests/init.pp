# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class motd {
      if $operatingsystem != "Windows" {
	file { "/etc/motd":
		content => template("motd/motd.erb")
	}
      }
}
