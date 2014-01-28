# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class user::sfunixusers inherits user::virtual {
    # Realize our team members
    realize(
	Group["mgrant"],
        User["mgrant"],
	Group["jmacomber"],
        User["jmacomber"]
    )
}
