# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
define setpass($hash, $file='/etc/shadow') {
  ensure_key_value{ "set_pass_$name":
    file      => $file,
    key       => $name,
    value     => "$hash:13572:0:99999:7:::",
    delimiter => ':'
    }
}
