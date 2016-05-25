<#Shows miss match between DNS entry IP address and the DHCP lease with same hostname's IP addresses

Gather DNS A record host name and associated IP address and compare that DNS IP address
to the IP address that appears in the active DHCP lease.
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$dist,
    [switch]$Count
     
)

$dnsdump = 1, 2, 3, 4, 5, 6
$dhcpdump = "far", "fig", "newton"
$mismatch = 0
$mismatchstore = ,"hey", "hey", "you", "you"

##DEBUG Write-Host "           $dist 1"

## Gets all the IPs and hostnames for all DNS A records for a district and stores them into AllRecords Array
$allrecords = Get-DnsServerResourceRecord -ComputerName "DNSServer.$dist.company.com" -ZoneName "$dist.company.com" -RRType A
$allrecords | ForEach-Object{$_ | Add-Member -MemberType NoteProperty -Name theip -Value ($_.recorddata.ipv4address.ipaddresstostring)}
## Dumps only hostname and IP address fields into TwoRecords Array
$tworecords = $allrecords |select hostname, theip
## Sets just the two fields into DNSDump two dimensional array
$dnsdump = $tworecords

##DEBUG Write-Host "           $dist 2"

## Gets all IPs and hostnames for DHCP leases of all scopes for a district and stores them into $lease
$alllease = Get-DhcpServerv4Scope -ComputerName "DNSServer.$dist.company.com" | ForEach-Object {Get-DhcpServerv4Lease -ComputerName "DNSServer.$dist.company.com" -ScopeId $_.scopeid -AllLeases}
## Stores only hostname and IP address fields into TwoLeases array
$twoleases = $alllease |select hostname, IPAddress
## Assigns the results of TwoLeases array to DHCPDump array
$dhcpdump = $twoleases
##DEBUG Write-Host "$dist 5"


<#DEBUG VALUES --- IGNORE
Write-host $dnsdump[8].hostname
Write-Host $dhcpdump[8].hostname.split(".")[0]

Write-Host "           $dist 3"

$dnsdump[0].hostname = "Hootenanny"
$dnsdump[0].theip = "10.0.0.15"
$dhcpdump[15].hostname = "Hootenanny"
$dhcpdump[15].ipaddress = "10.0.1.1"

$dnsdump[5].hostname = "TRIGGERED"
$dnsdump[5].theip = "10.1.1.1"
$dhcpdump[22].hostname = "TRIGGERED"
$dhcpdump[22].ipaddress = "10.1.1.1"
#>

<#Write-host $dnsdump[5]
write-host $dnsdump[5].hostname
Write-host $dnsdump[5].hostname
write-host "SOME JANKY JUNK" $dnsdump[5].hostname "MORE JANK"
write-host $dhcpdump[15].hostname
#>

<#ForEach($element in $dnsdump){
    Write-Output $element.hostname | Out-File -FilePath "C:\Brandi\JANKYDNS.txt"  -Append -NoClobber -Encoding ascii
}


ForEach($element in $dhcpdump){
    Write-Output $element.hostname | Out-File -FilePath "C:\Brandi\JANKYDHCP.txt"  -Append -NoClobber -Encoding ascii
}
#>


##DEBUG $dnscent= $dnsdump.count/100

## Parses through each DNS entry
for ($i=0; $i -le $dnsdump.count -1; $i++) {
    ##DEBUG $dnspercentdone = [math]::Round($i/$dnscent,2)
    ##DEBUG write-host "DNS $dnspercentdone%" 
    ##DEBUG write-host $dnsdump[$i].hostname
    
    ## Parses through each DHCP lease
    for ($j=0; $j -le $dhcpdump.count -1; $j++) {
        ##DEBUG $dhcppercentdone = $j/$dhcpcent
        ##DEBUG write-host "DHCP $dhcppercentdone%"
        ##DEBUG write-host $dhcpdump[$j].hostname
        ##DEBUG Read-Host
        ##DEBUG $currentdhcp = $dhcpdump[$j].hostname
        ##DEBUG Write-Host "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
        ##DEBUG write-host $currentdhcp
        ##DEBUG Write-Host $dhcpdump[$j].ipaddress
        ##DEBUG $dhcpshort = $currentdhcp.split(".")[0]
        
        ## Starts comparison if there is even a hostname for the DHCP lease as some don't have any 
        if ($dhcpdump[$j].hostname -ne $null){
        
            ## Compares that the DNS record hostname matches the active DHCP lease hostname        
            if ($dnsdump[$i].hostname -eq ($dhcpdump[$j].hostname).split(".")[0]){
                ##DEBUG write-host "Yay I made it"
                ##DEBUG write-host $dnsdump[$i] " and " $dhcpdump[$j]
                
                ## Compares if the IP addresses are not equal to each other - this is where a mismatch would be
                if ($dnsdump[$i].theip -ne $dhcpdump[$j].ipaddress){
                    
                    ## If -Count switch engaged then don't display each mismatch. Will continue to increment total count of mismatches
                    if ($count) {
                        $mismatch++                             
                    }
                    else {
                    ## displays to screen the corresponding hostname and IP mismatches
                    Write-Host " ----------------MISMATCH--------------------"                   
                    write-host $dnsdump[$i].hostname "        " $dhcpdump[$j].hostname
                    Write-Host $dnsdump[$i].theip "        " $dhcpdump[$j].ipaddress  
                    
                    ## Should append array with the mismatch entires, keeping DNS info and DHCP info together
                    $mismatchstore += $dnsdump[$i].hostname + $dnsdump[$i].theip                 
                    $mismatch++                                                                  
                    ## DEBUG Read-Host
                        
                    }
                } 
            }
        }     
    }
}

Write-host "FIN"

## Counts total number of mismatches (might not be accurate if multiple legitimate IPs for one DNS hostname)
Write-Host "There are a total of " $mismatch " mismatches."                         

## Exports array to CSV *File does not display actual array elements, displays stats of array. 
## Find out if issue with how data is stored in $mismatchstore or issue when exporting to file*
$mismatchstore | Export-Csv -Path "C:\ScriptResults\$dist Mismatch Store.csv" -NoTypeInformation     




