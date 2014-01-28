class tfound::windows ()
{
    notify{
      "Setting up Taylor Foundation Windows PC's":
    }
    service { 
      "puppet": ensure => running, enable => true; 
    }
    file { 'C:\Tfound':
      ensure => directory,
      owner => "Administrator",
      group => "Administrators",
      mode => '0777'
    }
    file { 'C:\Tfound\scripts':
      ensure => directory,
      owner => "Administrator",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Tfound']
    }
    file { 'C:\Tfound\run':
      ensure => directory,
      owner => "Administrator",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Tfound']
    }
    file { 'C:\Tfound\scripts\mountdrives.cmd':
      content => template("tfound/mountdrives.cmd.erb"),
      owner => "Administrator",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Tfound\scripts']
    }
    exec { 'mountdrives':
      command => 'C:\Tfound\scripts\mountdrives.cmd',
      require => File['C:\Tfound\scripts\mountdrives.cmd']
    }
#    exec { 'fixfiles':
#      command => 'C:\Windows\System32\takeown.exe /f C:\Miner49er\cgminer-3.7.2-windows\bitstreams',
#    }
#    exec { 'fixfiles2':
#      command => 'C:\Windows\System32\icacls.exe C:\Miner49er\cgminer-3.7.2-windows\bitstreams /reset',
#      require => Exec['fixfiles']
#    }
}
