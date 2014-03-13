# README for DnsManager

## Notes

This is a simple README file which explain how the script works.

This script is in first version, is made for bind9 on Debian.
However I think it can be use for other distros as well.

When you create a zone declaration files name it will be named based
on the domain name without the extension prefixed by "named.conf." :

	_Example_ :	Domain name = domain.ls
				zone Declaration file name = named.conf.domain
				
You can change the "named.conf." parameter, just modify the value of
the "namedConf" variable on the top of the file managerDns.sh.

Zone Definition files are named based on full domain name plus ".hosts" :

	_Example_ :	Domain name = domain.ls
				zone Definition file name = domain.ls.hosts
				
This can be change the ".hosts" parameter, just modify the value of the
"zoneDefSuf" variable ont the top of the file managerDns.sh.

When you create a zone Definition file the script add some default A field
like "www", "mail", "smtp",... It is hard codded for now but will change
in a future release.

You cannot add custom zone field with the script now but in a futur
it will be possible.

## Install

There is no real installation. just few things to edit :

			1 - Fill the "bindPath" variable with the bind root path,
				_(/etc/bind/ for example)_
			
			2 - Fill the "zoneDefPath" variable with the path where
				you store your zone definition file,
				_(/etc/bind/zoneFiles/ for example)_
			
			3 - Fill the "srvIP" variable with the IP you want to put
				in your A field _(This variable is use for default value,
				you can change it later. However when you create a sub
				domain this is the ip that is used.)_
			
			4 - Fill the "primDns" and "secDns" variables with the pimary
				and the secondary DNS sever hostname _(ns1.domain.fr)_ you
				usually use. There are use for default values.
				
			
			
__Do not forget to add execution right **(chmod u+x)** on it!__

## How it works

When you launch the script _(./manageDns.sh)_ a menu prompt. You can choose
among three options :

			1 - _Add a new zone to an existing zone file_ : This option list
				all existing zone Declaration file and allow you to add a
				new zone Declaration in an existing file then it creates
				the corresponding zone Definition file.

			2 - _Add new zone with new zone file_ : This option create a new
				zone Declaration file and a new zone Definition file.

			3 - _Add sub domain to an existing zone_ : This option allow
				you to add a sub domain in an existing zone Definition
				file.

			4 - _List existing zone **DECLARATION**_ : List all existing zone
				Declaration files.

			5 - _List existing zone **DEFINITION**_ : List all existing zone
				Definition files.

You just have to select an option and follow the instructions!