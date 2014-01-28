class miner( $mineruser = 'robojones', $minerpass = 'xxx', $domain = 'maskedadmins') 
{
  if $operatingsystem == "windows" {
#    exec { 'start_miner':
#      command => 'C:\Users\dtaylor\Downloads\miner49er\cgminer\cgminer-3.7.2-windows\start-mining-runfirst.cmd',
#      creates => 'C:\miner49er\miner.lock'
#    }
    scheduled_task { 'Reboot Handler 0':
      ensure    => present,
      enabled   => true,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '00:01',      # Must be specified
      }
    }
    scheduled_task { 'Reboot Handler 6':
      ensure    => present,
      enabled   => true,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '06:01',      # Must be specified
      }
    }
    scheduled_task { 'Reboot Handler 12':
      ensure    => present,
      enabled   => true,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '12:01',      # Must be specified
      }
    }
    scheduled_task { 'Reboot Handler 18':
      ensure    => present,
      enabled   => true,
      command   => 'C:\Windows\System32\shutdown.exe',
      arguments => '-t 0 -r -f',
      trigger   => {
        schedule   => daily,
        start_time => '18:01',      # Must be specified
      }
    }
    file { 'C:\Miner49er':
      ensure => directory,
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      recurse => true
    }
    file { 'C:\Miner49er\cgminer-3.7.2-windows':
      ensure => directory,
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777'
    }
    file { 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup-call-the-miner.lnk':
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      source => "puppet:///modules/miner/startup-call-the-miner.lnk",
    }
    file { 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\startup-mining-runfirst.lnk':
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      source => "puppet:///modules/miner/startup-mining-runfirst.lnk",
    }
    file { 'C:\Miner49er\autologin.cmd':
      content => template("miner/autologin.cmd.erb"),
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Miner49er']
    }
    file { 'C:\Miner49er\autologin.reg':
      content => template("miner/autologin.reg.erb"),
      owner => "$mineruser",
      group => "Administrators",
      mode => '0777',
      require => File['C:\Miner49er']
    }
    exec { 'miner-autologin':
      command => 'C:\Miner49er\autologin.cmd',
      require => [File['C:\Miner49er\autologin.cmd'],File['C:\Miner49er\autologin.reg']]
    }
  }
}
