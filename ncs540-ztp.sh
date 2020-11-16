#!/bin/bash


#############################################
# CPOC NCS540 Zero Touch Provisioning Script                
#############################################


export LOGFILE=/disk0:/ztp/cpoc-ztp.log
export RPM_DIR=http://10.67.183.8/public/image/NCS540-iosxr-k9-7.2.1/
export RPMS="ncs540-eigrp-1.0.0.0-r721.x86_64.rpm ncs540-isis-1.0.0.0-r721.x86_64.rpm ncs540-k9sec-1.0.0.0-r721.x86_64.rpm ncs540-li-1.0.0.0-r721.x86_64.rpm ncs540-mcast-1.0.0.0-r721.x86_64.rpm ncs540-mgbl-1.0.0.0-r721.x86_64.rpm ncs540-mpls-1.0.0.0-r721.x86_64.rpm ncs540-mpls-te-rsvp-1.0.0.0-r721.x86_64.rpm	 ncs540-ospf-1.0.0.0-r721.x86_64.rpm"

## source all bash helper libraries
source /pkg/bin/ztp_helper.sh

function ztp_log() {
    # Sends logging information to local file only
    echo "$(date +"%b %d %H:%M:%S") "$1 >> $LOGFILE
}

fuction check_rpms(){
	complete=`xrcmd "show install active" | grep k9sec | head -n1 | wc -l`
	ztp_log "Waiting for k9sec package to be activated"
}

function install_all_rpms(){
    # Installs all packages
	xrcmd "install add source $RPM_DIR $RPMS" 2>&1 >> $LOGFILE
    if [[ "$?" != 0 ]]; then
        ztp_log "error adding packages from http"
	fi
	
	xrcmd "install activate *r721 noprompt"
    if [[ "$?" != 0 ]]; then
        ztp_log "package activation failed"
	fi

	if [[ -z $(xrcmd "show crypto key mypubkey rsa") ]]; then
		echo "2048" | xrcmd "crypto key generate rsa"
	else
		echo -ne "yes\n 2048\n" | xrcmd "crypto key generate rsa"
	fi
	
	ztp_log "### XR K9SEC INSTALL COMPLETE ###"
}


# ==== Script entry point ====
ztp_log "Starting autoprovision process...";
install_all_rpms;

#add some day0
ztp_log "Applying vrf mgmt commands"
cat >/tmp/config <<EOF
!!!!!!!!!!!! XR bootstrap
username cisco
 group root-lr
 group cisco-support
 secret #############
!

 vrf mgmt
 add ipv4 uni 
 
 
interface MgmtEth0/RP0/CPU0/0
 vrf mgmt
 no ipv4 address
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
