# ZTP autoprovisioning scripts for XR devices

ZTP provisioning script demo

### Device Support
Script supports following devices
- NCS5500 series
- NCS540 (non ARM)
- ASR 9000, 9900 Running eXR code

Upgrade, downgrade from cXR versions is currently not supported.

### Requirements
DHCP server serving iPXE boot image and xr-config script
HTTP server hosting ZTP script and all required rpms

### Notes
Device will maintain IPV4 address and default mgmt route via DHCP
Support for static IPs is currently not implemented. 
Support for hostnames is currently not implemented

### Example
![image](https://user-images.githubusercontent.com/6979581/146726927-faee58f5-8b15-4f41-825f-037d43f4f9f9.png)
