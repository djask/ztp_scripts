#!/bin/bash


#############################################
# CPOC Zero Touch Provisioning Script                
#############################################


export LOGFILE=/disk0:/ztp/cpoc-ztp.log

## source all bash helper libraries
source /pkg/bin/ztp_helper.sh

function detect_platform() {
	ztp_log "getting platform"
	xrcmd "show plat" | grep "N540-24Z8Q2C-M"
	if [[ "$?" == 0 ]]; then
		ztp_log "detect_platform: NCS540"
		#export RPM_DIR=http://10.67.183.8/public/image/ncs540-731/
		#export RPMS="ncs540-bgp-1.0.0.0-r73136I.x86_64.rpm ncs540-eigrp-1.0.0.0-r73136I.x86_64.rpm ncs540-isis-1.0.0.0-r73136I.x86_64.rpm ncs540-k9sec-1.0.0.0-r73136I.x86_64.rpm ncs540-li-1.0.0.0-r73136I.x86_64.rpm ncs540-mcast-1.0.0.0-r73136I.x86_64.rpm ncs540-mgbl-1.0.0.0-r73136I.x86_64.rpm ncs540-mpls-1.0.0.0-r73136I.x86_64.rpm ncs540-mpls-te-rsvp-1.0.0.0-r73136I.x86_64.rpm ncs540-ospf-1.0.0.0-r73136I.x86_64.rpm ncs540-xcare-1.0.0.0-r73136I.x86_64.rpm"
		export RPM_DIR=http://10.67.183.8/public/image/NCS540-iosxr-k9-7.1.2/
		export RPMS="ncs540-eigrp-1.0.0.0-r712.x86_64.rpm ncs540-isis-1.0.0.0-r712.x86_64.rpm ncs540-k9sec-1.1.0.0-r712.x86_64.rpm ncs540-li-1.0.0.0-r712.x86_64.rpm ncs540-mcast-1.0.0.0-r712.x86_64.rpm ncs540-mgbl-1.0.0.0-r712.x86_64.rpm ncs540-mpls-1.0.0.0-r712.x86_64.rpm ncs540-mpls-te-rsvp-1.0.0.0-r712.x86_64.rpm ncs540-ospf-1.0.0.0-r712.x86_64.rpm"
		return 0
	fi 
	
	xrcmd "show plat" | grep -e "(NCS-550|NC55)"
	if [[ "$?" == 0 ]]; then
		ztp_log "detect_platform: NCS5500"
		#export RPM_DIR=http://10.67.183.8/public/image/NCS5500-iosxr-k9-6.6.25/
		#export RPMS="ncs5500-isis-2.1.0.0-r6625.x86_64.rpm   ncs5500-mcast-2.1.0.0-r6625.x86_64.rpm  ncs5500-mpls-2.1.0.0-r6625.x86_64.rpm     ncs5500-k9sec-3.1.0.0-r6625.x86_64.rpm  ncs5500-mgbl-3.0.0.0-r6625.x86_64.rpm   ncs5500-mpls-te-rsvp-3.1.0.0-r6625.x86_64.rpm ncs5500-li-1.0.0.0-r6625.x86_64.rpm        ncs5500-ospf-2.0.0.0-r6625.x86_64.rpm"
		export RPM_DIR=http://10.67.183.8/public/image/NCS5500-iosxr-k9-7.1.2/
		export RPMS="ncs5500-eigrp-1.0.0.0-r712.x86_64.rpm ncs5500-isis-2.1.0.0-r712.x86_64.rpm ncs5500-k9sec-3.2.0.0-r712.x86_64.rpm ncs5500-li-1.0.0.0-r712.x86_64.rpm ncs5500-mcast-3.0.0.0-r712.x86_64.rpm ncs5500-mgbl-3.0.0.0-r712.x86_64.rpm ncs5500-mpls-2.1.0.0-r712.x86_64.rpm ncs5500-mpls-te-rsvp-3.1.0.0-r712.x86_64.rpm ncs5500-ospf-2.0.0.0-r712.x86_64.rpm"
		return 0
	fi 
	
	xrcmd "show plat" | grep -e "A9K-*|A99-*"
	if [[ "$?" == 0 ]]; then
		ztp_log "detect_platform: ASR9k"
		export RPM_DIR=http://10.67.183.8/public/image/asr9k-x64/
		export RPMS="asr9k-mpls-te-rsvp-x64-2.1.0.0-r73136I.x86_64.rpm asr9k-mpls-te-rsvp-x64-2.1.0.0-r7399.x86_64.rpm asr9k-mpls-x64-2.0.0.0-r73136I.x86_64.rpm asr9k-mpls-x64-2.0.0.0-r7399.x86_64.rpm asr9k-optic-x64-1.0.0.0-r73136I.x86_64.rpm asr9k-optic-x64-1.0.0.0-r7399.x86_64.rpm asr9k-ospf-x64-1.0.0.0-r73136I.x86_64.rpm asr9k-ospf-x64-1.0.0.0-r7399.x86_64.rpm asr9k-parser-x64-2.0.0.0-r73136I.x86_64.rpm asr9k-parser-x64-2.0.0.0-r7399.x86_64.rpm asr9k-services-x64-1.0.0.0-r73136I.x86_64.rpm asr9k-services-x64-1.0.0.0-r7399.x86_64.rpm asr9k-xcare-x64-1.0.0.0-r73136I.x86_64.rpm asr9k-xcare-x64-1.0.0.0-r7399.x86_64.rpm"
		return 0
	fi 
	
	return 1
}

function ztp_log() {
    # Sends logging information to local file only
    echo "$(date +"%b %d %H:%M:%S") "$1 >> $LOGFILE
}

function install_all_rpms(){
    # Installs all packages
	xrcmd "install add source $RPM_DIR $RPMS" 2>&1 >> $LOGFILE
    if [[ "$?" != 0 ]]; then
        ztp_log "error adding packages from http"
		return 1
	fi
	
	xrcmd "install activate *r6625 noprompt"
    if [[ "$?" != 0 ]]; then
        ztp_log "package activation failed"
		return 1
	fi

	if [[ -z $(xrcmd "show crypto key mypubkey rsa") ]]; then
		echo "2048" | xrcmd "crypto key generate rsa"
	else
		echo -ne "yes\n 2048\n" | xrcmd "crypto key generate rsa"
	fi
	
	ztp_log "rpm add complete, committing"
	xrcmd "install commit"
	return 0
}


# ==== Script entry point ====
ztp_log "Starting autoprovision process...";
detect_platform;

ztp_log "rpm dir $RPM_DIR"
ztp_log "rpms $RPMS"


if [[ "$?" == 1 ]]; then
	ztp_log "did not find recognised platform"
	exit 1
fi

ztp_log "platform detection complete"

install_all_rpms;

#add some day0
ztp_log "Applying vrf mgmt commands"
cat >/tmp/config <<EOF
!!!!!!!!!!!! XR bootstrap
username cisco
 group root-lr
 group cisco-support
 secret ###########
!

 vrf mgmt
 add ipv4 uni 
 
 
interface MgmtEth0/RP0/CPU0/0
 vrf mgmt
 ipv4 address dhcp
 no shut
!

router static
 vrf mgmt
  address-family ipv4 unicast
   0.0.0.0/0 10.67.183.1
  !
 !
!

ssh server vrf mgmt
http client vrf mgmt
EOF

xrreplace /tmp/config

ztp_log "Autoprovision complete...";
exit 0