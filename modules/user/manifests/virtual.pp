# vim:set noet:
# vim:set sts=8 ts=8:
# vim:set shiftwidth=8:
class user::virtual {
    @user { "dtaylor":
        ensure  => "present",
#        uid     => "2000",
#        gid     => "2000",
        comment => "David Taylor",
        home    => "/home/dtaylor",
        shell   => "/bin/bash",
	managehome  =>  "true"
	;
	"zenoss":
	uid	=> "5000",
	gid	=> "5000",
	ensure 	=> "present",
	comment	=> "Zenoss User",
	home 	=> "/home/zenoss",
	shell	=> "/bin/bash",
	managehome  =>  "true"
	;
	}
     @group { "dtaylor": 
#	gid => "2000",
	ensure => present
	;
	"zenoss":
	gid	=> "5000",
	ensure 	=> present
	}
}
