# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class user::unixadmins inherits user::virtual {
    # Realize our team members
    realize(
	Group["dtaylor"],
        User["dtaylor"]
    )

	setpass { "dtaylor": hash     => '$6$GP/VAQ3k$i6xEQR2hecAWCD/tVR/hlpiwfeE/6GKgF2BazZD.4kClZDy1U3h6UpGLIZKidxQTl8FKBW.4AaHllFWui51lb.'}

}
