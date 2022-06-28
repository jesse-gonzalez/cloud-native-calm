$dnshost = "@@{dns_name}@@"
$dnszone = "@@{domain_name}@@"
$dnsserver = "@@{dns_server}@@"
$dnsipaddr = "@@{dns_ip_address}@@"

$dns_ptr_ip = "@@{ip_number}@@"
$dns_ptr_zone = "@@{reversed_ip}@@.in-addr.arpa"
$dns_domain_name = "@@{dns_name}@@.@@{domain_name}@@"


## Updating DNS Server A Record
$oldobj = Get-DnsServerResourceRecord -Name $dnshost -ZoneName $dnszone -RRType "A" -ComputerName $dnsserver -ErrorAction Stop
Write-Output($oldobj)
If ($oldobj -eq $null)
{ 
    #Object does not exist in DNS, creating new one 
    Add-DnsServerResourceRecordA -CreatePtr -Name $dnshost -ZoneName $dnszone -IPv4Address $dnsipaddr -ComputerName $dnsserver -PassThru -Verbose
} 
Else
{ 
    $newobj = $oldobj.Clone()
    $newobj.RecordData.ipv4address = [System.Net.IPAddress]::parse($dnsipaddr)
    If (($newobj.RecordData.PtrDomainName -ine $oldobj.RecordData.PtrDomainName)) 
    { 
        #Objects are different: old - $oldobj, new - $newobj. Performing change in DNS 
        Set-dnsserverresourcerecord -newinputobject $newobj -oldinputobject $oldobj -ZoneName $dnszone -PassThru -ComputerName $dnsserver -Verbose 

    } 
} 
$oldobj = $null 
$newobj = $null

## Updating DNS Server PTR Record
Write-Output($oldobj)
$oldobj = Get-DnsServerResourceRecord -ZoneName $dns_ptr_zone -RRType Ptr -ComputerName $dnsserver | Where-Object {$_.RecordData.PtrDomainName -like $dns_domain_name } -ErrorAction Stop
If ($oldobj -eq $null) 
{ 
    #Object does not exist in DNS, creating new one 
    Add-DnsServerResourceRecordPtr -Name $dns_ptr_ip -ZoneName $dns_ptr_zone -PtrDomainName $dns_domain_name -ComputerName $dnsserver -Verbose 
} 
Else
{ 
    $newobj = $oldobj.Clone()
    $newobj.RecordData.ipv4address = [System.Net.IPAddress]::parse($dnsipaddr)
    If (($newobj.RecordData.PtrDomainName -ine $oldobj.RecordData.PtrDomainName)) 
    { 
        #Objects are different: old - $oldobj, new - $newobj. Performing change in DNS 
        Set-DnsServerResourceRecord -NewInputObject $newobj -OldInputObject $oldobj -ZoneName $dns_ptr_zone -PassThru -ComputerName $dnsserver -Verbose 
    } 
}

$oldobj = $null 
$newobj = $null 


#Add-DnsServerResourceRecordA -Name @@{dns_name}@@ -ZoneName @@{domain_name}@@ -IPv4Address @@{dns_ip_address}@@ -ComputerName @@{dns_server}@@

#Add-DnsServerResourceRecordPtr -Name '@@{ip_number}@@' -ZoneName '@@{reversed_ip}@@.in-addr.arpa' -PtrDomainName '@@{dns_name}@@.@@{domain_name}@@' -ComputerName @@{dns_server}@@

#$dnsrecord = "@@{dns_record}@@"
#$dnshost = $dnsrecord.Split(".")[0]
#$dnszone = ($dnsrecord -split $dnshost,2)[1].substring(1)

# try {
#     $oldobj = Get-DnsServerResourceRecord -Name $dnshost -ZoneName $dnszone -RRType "A" -ComputerName $dnsserver -ErrorAction Stop
#     $newobj = $oldobj.Clone()
#     $newobj.RecordData.ipv4address = [System.Net.IPAddress]::parse($dnsipaddr)
#     Set-dnsserverresourcerecord -newinputobject $newobj -oldinputobject $oldobj -ZoneName $dnszone -PassThru -ComputerName $dnsserver
# }
# catch {
#     Add-DnsServerResourceRecordA -CreatePtr -Name $dnshost -ZoneName $dnszone -IPv4Address $dnsipaddr -ComputerName $dnsserver -PassThru
#     exit
# }
# try {
#     $oldobj = Get-DnsServerResourceRecord -ZoneName $dns_ptr_zone -RRType Ptr -ComputerName $dnsserver | Where-Object {$_.RecordData.PtrDomainName -like $dns_domain_name } -ErrorAction Stop
#     $newobj = $oldobj.Clone()
#     $newobj.RecordData.ipv4address = [System.Net.IPAddress]::parse($dnsipaddr)
#     Set-dnsserverresourcerecord -newinputobject $newobj -oldinputobject $oldobj -ZoneName $dnszone -PassThru -ComputerName $dnsserver
# }
# catch {
#     Add-DnsServerResourceRecordPtr -Name $dns_ptr_ip -ZoneName $dns_ptr_zone -PtrDomainName $dns_domain_name -ComputerName $dnsserver
#     exit
# }
