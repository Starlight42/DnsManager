#!/bin/bash
##########################
#######  INCLUDE  ########
##########################
## Variables Definition ##
bindPath=''
zoneDefPath=''
namedConf='named.conf.'
srvIP=''
primDns='.'
secDns='.'

## Functiona definitiona ##
# List all the existing zone declaration files #
listExistingDecFiles()
{
    for file in ${bindPath}*
    do
	if [[ -f $file && ${file#$bindPath} = named.conf* ]]; then
	    echo ${file#$bindPath};
	fi
    done
}

# Get the zone declaration file to modify #
getFileName()
{
    read -p 'Enter file name wth [named.conf.]: ' zoneName
    fileZonePath=${bindPath}${namedConf}${zoneName}
    read -p "Filename choosen : $fileZonePath. Are you sure ? [yes|no] : " answFilePath

    case $answFilePath in
	'yes'|'y'|'Y'|'Yes'|'')
	    echo 'good!'
	    ;;
	'no')
	    getFileName
	    ;;
	*)
	    echo 'you have put a wrong answer'
	    getFileName
	    ;;
    esac

    ## Check if the domain exists ##
    if [[ ! -f $fileZonePath ]]; then
	echo "File : $fileZonePath not found!";
	getFileName
    fi
}

# Add a zone in an existing zone declaration file and #
# Create the corresponding zone definition file #
addZone()
{
    echo 'List of existing zones def files :'
    listExistingDecFiles
    getFileName
    
    ## insert zone declaration in the selected file ##
    echo "" >> $fileZonePath
    echo $zoneContent >> $fileZonePath
    
    ## Split inserted line to look more beautifull ##
    sed -i -e "/zone \"$dname\"/s/ { / {\n\t/g;/master; file/s/; /;\n\t/g" $fileZonePath	    

    ## Create zone Definition file ##
    createZoneDef

    echo "Zone added in $fileZonePath and definition file created!!!"
}

# Create a zone declaration file and put a zone in it plus #
# Create the corresponding zone definition file #
createZoneDec()
{
    dnameWthExt=$(echo $dname | cut -d '.' -f1)
    newFileZonePath=${bindPath}${namedConf}${dnameWthExt}

    touch $newFileZonePath
    chown bind:bind $newFileZonePath
    
    ## insert zone declaration in the new file ##
    echo $zoneContent >> $newFileZonePath
    
    ## Split inserted line to look more beautifull ##
    sed -i -e "/zone \"$dname\"/s/ { / {\n\t/g;/master; file/s/; /;\n\t/g" $newFileZonePath
	    
    ## Create zone Definition file ##
    createZoneDef

    echo 'Definition and Declaration files created!!!'
}

# Get the domain name #
domainName()
{
    read -p 'Enter a domain name : ' dname;
    read -p "Your entered : $dname is that correct ? [yes|no] : " answ;

    case $answ in
	'yes'|'y'|'Y'|'Yes'|'')
	    echo 'good!'
	    ;;
	'no')
	    domainName
	    ;;
	*)
	    echo 'you have put a wrong answer'
	    domainName
	    ;;
    esac

    ## Set zone definition path ##
    zoneDefFile=${bindPath}zoneFiles/${dname}.hosts
}

## Get the sub domain name
subDomainName()
{
    read -p 'Enter the sub domain name you want to add : ' subDName
    read -p "Your entered : $subDName is that correct ? [yes|no] : " answ;

    case $answ in
	'yes'|'y'|'Y'|'Yes'|'')
	    echo 'good!'
	    ;;
	'no')
	    subDomainName
	    ;;
	*)
	    echo 'you have put a wrong answer'
	    subDomainName
	    ;;
    esac
}


## Create Zone Definition file
createZoneDef()
{
    # Create serial #
    defaultSerial=$(date +%Y%m%d)
    # Create the file #
    touch $zoneDefFile
    
    # Question to configure zone file #
    echo "Configuration of the zone $zoneDefFile :"
    read -p 'Enter a ttl : ' -e -i 86400 ttl
    read -p 'Enter a hostmaster address : ' -e -i "hostmaster.${dname}." hostmaster
    read -p 'Enter a serial : ' -e -i "${defaultSerial}00" serial
    read -p 'Enter a refresh frequency : ' -e -i 21600 refresh
    read -p 'Enter a retry frequency : ' -e -i 3600 retry
    read -p 'Enter an expire delay : ' -e -i 604800 expire
    read -p 'Enter a minimum : ' -e -i 86400 minimum
    read -p 'Enter the primary DNS srv : ' -e -i $primDns primaryDns
    read -p 'Enter the secondary DNS srv : ' -e -i $secDns secondaryDns
    read -p 'Enter the mail srv : ' -e -i "mail.${dname}." mailSrv
    read -p 'Enter the priority for the mail srv : ' -e -i 10 priority
    read -p 'Enter the IP address for the main A field : ' -e -i $srvIP IPAddress

    echo 'Compiling all the informations...'
    # Cause it's mor funny like this :) #
    sleep 1
    
    # Set zone with good values #
    zoneDef="\$ttl ${ttl}NL${dname}.TAB1INTAB1SOATAB1${dname}. ${hostmaster} 
	(NLTAB3${serial}NLTAB3${refresh}NLTAB3${retry}NLTAB3${expire}NLTAB3${minimum} )NLNL
	${dname}.TAB1INTAB1NSTAB1${primaryDns}NL
	${dname}.TAB1INTAB1NSTAB1${secondaryDns}NLNL
	${dname}.TAB1INTAB1MXTAB1${priority} ${mailSrv}NLNL
	${dname}.TAB1INTAB1ATAB1${IPAddress}NL
	nsTAB2INTAB1ATAB1${IPAddress}NL
	wwwTAB2INTAB1ATAB1${IPAddress}NL
	mailTAB2INTAB1ATAB1${IPAddress}NL
	smtpTAB2INTAB1ATAB1${IPAddress}NL
	popTAB2INTAB1ATAB1${IPAddress}NL
	pop3TAB2INTAB1ATAB1${IPAddress}NL
	imapTAB2INTAB1ATAB1${IPAddress}NL"

    # Fill the file with all the information #
    echo $zoneDef > $zoneDefFile
    
    # Cleaning the file to make it syntactically OK #
    sed -i -e 's/NL/\n/g;s/TAB1/\t/g;s/TAB2/\t\t/g;s/TAB3/\t\t\t/g'  $zoneDefFile

    # Change user and group of the zone def file #
    chown bind:bind $zoneDefFile
}

## Add a sub domain to an existing zone definition ##
addSubDomain()
{
    ## Get the sub domain name ##
    subDomainName

    ## Check if zoneDefFile exists ##
    if [[ ! -f $zoneDefFile ]]; then
	echo "File : $zoneDefFile not found!";
	domainName;
	addSubDomain;
    fi
    ## Set the sub domain name entry ##
    subDomain="${subDName}TAB2INTAB1ATAB1${srvIP}NLwww.${subDName}TAB1INTAB1ATAB1${srvIP}"

    ## Fill the sub domain file ##
    echo $subDomain >> $zoneDefFile

    ## Clean the sub domain definition ##
    sed -i -e 's/NL/\n/g;s/TAB1/\t/g;s/TAB2/\t\t/g'  $zoneDefFile

    ## Increment the zone serial ##
    sValue=$(sed -n '3p' $zoneDefFile)
    newSValue=$((sValue + 1))

    ## Replace new serial in zone def file ##
    sed -i "s/${sValue}/\t\t\t${newSValue}/g" $zoneDefFile
}

# Main script menu #
mainMenu()
{
    echo 'This script allow you to manage domain and zone files'
    echo '[1] - Add new zone to an existing zone file'
    echo '[2] - Add new zone with new zone file'
    echo '[3] - Add sub domain to an existing zone'
    read -p 'What is your choice? [1|2|3] : ' mainChoice

    domainName

    ## Define the zone information ##
    zoneContent="zone \"$dname\" {
    type master;
    file \"${bindPath}zoneFile/$dname.hosts\";
    notify-source 212.83.137.218;
    allow-transfer {91.121.173.158;};
    notify yes;
    };"

    case $mainChoice in
	'1')
	    addZone
	    ;;
	'2')
	    createZoneDec
	    ;;
	'3')
	    addSubDomain
	    ;;
	*)
	    echo 'nothing'
	    ;;
    esac
}

#############################
## Beginning of the script ##
#############################
## Check privileges ##
if [ "$(whoami)" != "root" ]; then
    echo "You don't have sufficient privilege to run this script."
    exit 1
fi

mainMenu

exit 0
