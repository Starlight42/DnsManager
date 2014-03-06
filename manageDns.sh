#!/bin/bash
##########################
#######  INCLUDE  ########
##########################
## Variables Definition ##
#Here go your bind path "/etc/bind/" ?
bindPath=''
#Here go your zone files definitions
zoneDefPath="${bindPath}zoneFiles/"
namedConf='named.conf.'
#Here go your web server address IP
srvIP=''
#Here go your primary Dns srv
primDns=''
#Here go your secondary Dns srv
secDns=''

# Bold Color for general case #
DEFAULT="\e[0m"
WHITE="\e[1;97m"
GREEN="\e[1;32m"
LGREEN="\e[1;92m"
RED="\e[1;31m"
LRED="\e[1;91m"
MAGENTA="\e[1;35m"
LMAGENTA="\e[1;95m"
BLUE="\e[1;34m"
LBLUE="\e[1;94m"
YELLOW="\e[1;33m"
LYELLOW="\e[1;93m"
CYAN="\e[1;36m"
LCYAN="\e[1;96m"

# Bold Color for READ -p case #
RDEFAULT=$'\E[0m'
RWHITE=$'\E[1;97m'
RGREEN=$'\E[1;32m'
RLGREEN=$'\E[1;92m'
RRED=$'\E[1;31m'
RLRED=$'\E[1;91m'
RMAGENTA=$'\E[1;35m'
RLMAGENTA=$'\E[1;95m'
RBLUE=$'\E[1;34m'
RLBLUE=$'\E[1;94m'
RYELLOW=$'\E[1;33m'
RLYELLOW=$'\E[1;93m'
RCYAN=$'\E[1;36m'
RLCYAN=$'\E[1;96m'

## Functions definitions ##
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
    read -p "${RWHITE}Enter file name ${RRED}without \"named.conf.\"${RDEFAULT}: " zoneName
    fileZonePath=${bindPath}${namedConf}${zoneName}
    read -p "${RWHITE}Filename choosen : ${RLRED}$fileZonePath. ${RWHITE}Are you sure ? [yes|no] : ${RDEFAULT}" answFilePath

    case $answFilePath in
	'yes'|'y'|'Y'|'Yes'|'')
	    echo -e "${CYAN}good!${DEFAULT}"
	    ;;
	'no')
	    getFileName
	    ;;
	*)
	    echo -e "${RED}you have put a wrong answer!${DEFAULT}"
	    getFileName
	    ;;
    esac

    ## Check if the domain exists ##
    if [[ ! -f $fileZonePath ]]; then
	echo -e "${RED}File : $fileZonePath not found!${DEFAULT}";
	getFileName
    fi
}

# Add a zone in an existing zone declaration file and #
# Create the corresponding zone definition file #
addZone()
{
    echo -e "${WHITE}List of existing zones def files :${DEFAULT}"
    listExistingDecFiles
    getFileName
    
    ## insert zone declaration in the selected file ##
    echo "" >> $fileZonePath
    echo $zoneContent >> $fileZonePath
    
    ## Split inserted line to look more beautifull ##
    sed -i -e "/zone \"$dname\"/s/ { / {\n\t/g;/master; file/s/; /;\n\t/g" $fileZonePath	    

    ## Create zone Definition file ##
    createZoneDef

    echo -e "${CYAN}Zone added in ${RED}$fileZonePath${CYAN} and definition file created!!!${DEFAULT}"
}

# Create a zone declaration file and put a zone in it plus #
# Create the corresponding zone definition file #
createZoneDec()
{
    echo -e "${WHITE}Creating declaration file...${DEFAULT}"

    dnameWthExt=$(echo $dname | cut -d '.' -f1)
    newFileZonePath=${bindPath}${namedConf}${dnameWthExt}

    touch $newFileZonePath
    chown bind:bind $newFileZonePath
    
    ## insert zone declaration in the new file ##
    echo $zoneContent > $newFileZonePath
    
    ## Split inserted line to look more beautifull ##
    sed -i -e "/zone \"$dname\"/s/ { / {\n\t/g;/master; file/s/; /;\n\t/g" $newFileZonePath

    echo -e "${CYAN}Declaration file created!!!${DEFAULT}"
}

# Get the domain name #
domainName()
{
    read -p "Enter a domain name : " dname;
    read -p "Your entered : ${RRED}$dname${RWHITE} is that correct ? [yes|no] : " answ;

    case $answ in
	'yes'|'y'|'Y'|'Yes'|'')
	    echo -e "${CYAN}good!${DEFAULT}"
	    ;;
	'no')
	    domainName
	    ;;
	*)
	    echo -e "${RED}you have put a wrong answer${DEFAULT}"
	    domainName
	    ;;
    esac

    ## Set zone definition path ##
    zoneDefFile=${bindPath}zoneFiles/${dname}.hosts
}

## Get the sub domain name
subDomainName()
{
    read -p "${RWHITE}Enter the sub domain name you want to add : " subDName
    read -p "Your entered : ${RRED}$subDName${RWHITE} is that correct ? [yes|no] : ${RDEFAULT}" answ;

    case $answ in
	'yes'|'y'|'Y'|'Yes'|'')
	    echo -e "${CYAN}good!${DEFAULT}"
	    ;;
	'no')
	    subDomainName
	    ;;
	*)
	    echo -e "${RED}you have put a wrong answer${DEFAULT}"
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
    echo -e "${WHITE}Configuration of the zone : ${CYAN}$zoneDefFile${WHITE} :${DEFAULT}"
    read -p "${RWHITE}Enter a ${RCYAN}ttl${RWHITE} : " -e -i 86400 ttl
    read -p "Enter a ${RCYAN}hostmaster address${RWHITE} : " -e -i "hostmaster.${dname}." hostmaster
    read -p "Enter a ${RCYAN}serial${RWHITE} : " -e -i "${defaultSerial}00" serial
    read -p "Enter a ${RCYAN}refresh frequency${RWHITE} : " -e -i 21600 refresh
    read -p "Enter a ${RCYAN}retry frequency${RWHITE} : " -e -i 3600 retry
    read -p "Enter an ${RCYAN}expire delay${RWHITE} : " -e -i 604800 expire
    read -p "Enter a ${RCYAN}minimum${RWHITE} : " -e -i 86400 minimum
    read -p "Enter the ${RCYAN}primary DNS srv${RWHITE} : " -e -i $primDns primaryDns
    read -p "Enter the ${RCYAN}secondary DNS srv${RWHITE} : " -e -i $secDns secondaryDns
    read -p "Enter the ${RCYAN}mail srv${RWHITE} : " -e -i "mail.${dname}." mailSrv
    read -p "Enter ${RCYAN}priority for the mail srv${RWHITE} : " -e -i 10 priority
    read -p "Enter the ${RCYAN}IP address for the main A field${RWHITE} : " -e -i $srvIP IPAddress

    echo -e "${WHITE}Compiling all the informations...${DEFAULT}"
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

    echo -e "${CYAN}Zone definition file successfully created!!${DEFAULT}"
}

## Add a sub domain to an existing zone definition ##
addSubDomain()
{
    ## Get the sub domain name ##
    subDomainName

    ## Check if zoneDefFile exists ##
    if [[ ! -f $zoneDefFile ]]; then
	echo -e "${RED}File : $zoneDefFile not found!${DEFAULT}";
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

    echo -e "${CYAN}Sub domain successfully created!!${DEFAULT}"
}

# Main script menu #
mainMenu()
{
    echo -e "${WHITE}This script allow you to manage domain and zone files"
    echo -e "${CYAN}[1] ${RED}-${DEFAULT} ${WHITE}Add new zone to an existing zone file${DEFAULT}"
    echo -e "${CYAN}[2] ${RED}-${DEFAULT} ${WHITE}Add new zone with new zone file${DEFAULT}"
    echo -e "${CYAN}[3] ${RED}-${DEFAULT} ${WHITE}Add sub domain to an existing zone${DEFAULT}"
    read -p "${RWHITE}What is your choice ? ${RCYAN}[1${RRED}|${RCYAN}2${RRED}|${RCYAN}3]${RWHITE} : " mainChoice

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
	    createZoneDef
	    ;;
	'3')
	    addSubDomain
	    ;;
	*)
	    echo "${WHITE}Bad argument! Retry${DEFAULT}"
	    mainMenu
	    ;;
    esac
}

#############################
## Beginning of the script ##
#############################
## Check privileges ##
if [ "$(whoami)" != "root" ]; then
    echo "${RED}You don't have sufficient privilege to run this script.${DEFAULT}"
    exit 1
fi

mainMenu

exit 0
