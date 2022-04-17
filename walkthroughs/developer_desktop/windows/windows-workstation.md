

SETX KUBECONFIG "C:\Users\Administrator\Downloads\YOUR-KARBON-CLUSTER-NAME-kubectl.cfg"

Open / Close Powershell

$env:KUBECONFIG


Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "10.55.5.123`tgrafana.lab.local" -Force
cat C:\Windows\System32\drivers\etc\hosts

Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value "10.55.5.123`tk10.lab.local" -Force
cat C:\Windows\System32\drivers\etc\hosts

Invoke-Command -ComputerName dc.ntnxlab.local -ScriptBlock {Add-DnsServerResourceRecordA -Name "ntnx-objects" -ZoneName "ntnxlab.local" -AllowUpdateAny -IPv4Address "10.55.4.18"}
Invoke-Command -ComputerName dc.ntnxlab.local -ScriptBlock {Add-DnsServerResourceRecordA -Name "user06-k10-bucket.ntnx-objects" -ZoneName "ntnxlab.local" -AllowUpdateAny -IPv4Address "10.55.4.18"}


kubectl edit coredns
ntnxlab.local:53 {
   errors
   cache 30
   forward . 10.55.4.41
}
