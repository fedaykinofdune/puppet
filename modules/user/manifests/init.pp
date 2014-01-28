# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
#import "*"
import 'keyvalue.pp'
class user {
    include user::virtual, user::unixadmins
}
