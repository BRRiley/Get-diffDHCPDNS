# Get-diffDHCPDNS

Returns the hostnames and IP addresses of mismatches between a DNS record's IP and it's active DHCP lease's IP in a domain

I wrote this script to assist with troubleshooting workstations that have different IP addresses than what their DNS record has them listed for. Previously, affected workstations were only discovered by happenstance when trying to RDP into a machine via DNS and was not looking at the correct system. 

Running this script will give all instances of mismatching IP address of a DNS A record and the DHCP lease of the same hostname to better see full scope of issue and specifically pinpoint affected machines to aid with investigation.

#Commands

Parameters:
 -dist     Mandatory string value for unique part of domain name within a multi-domain environment.
           To apply this to your own environment, you will want to replace all instances of $dist with your company's DNS server and DNS server zone name. If both of those don't share a similar string value then another mandatory string parameter would be required. One for DNS Server name and another for DNS server zone name. This could be an IP address or anything that resolves to an IP address such as FQDN, hostname, or NETBIOS name.
           
           This will output to screen every mismatch as such:
            ----------------MISMATCH--------------------
            DNS Hostname                  DHCP Hostname
            DNS IP Address                DHCP IP Address
           
           Along with total number of mismatches detected shown as:
           There are a total of  ###  mismatches.
           

Switches:
 -Count    Switch that will only display the total number of mismatched entries. Will not output each entry to screen.
 
 
#Requirements

Script is a .ps1 filetype written for Powershell 5.0

Windows PowerShell 5.0 runs on the following versions of Windows:
    •Windows 10, installed by default

    •Windows 8.1, Powershell 4.0 installed by default

    •Windows Server 2012 R2, Powershell 4.0 installed by default

    •Windows® 7 with Service Pack 1, install Windows Management Framework 4.0 to run Windows PowerShell 4.0

    •Windows Server® 2008 R2 with Service Pack 1, install Windows Management Framework 4.0 to run Windows PowerShell 4.0


