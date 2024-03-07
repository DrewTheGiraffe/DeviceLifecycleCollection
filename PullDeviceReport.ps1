# Pull Device Info for LifeCycle | Drew Burgess 2024

$a = (get-adcomputer -Filter 'OperatingSystem -like "*Windows*"').Name
$result=@() 

$c = foreach ($b in $a) {

    $sn = $null
    $cs = $null
    $cs = $null
    $nt = $null
    $dt = $null
    $bd = $null
    $pr = $null
    $nt = (Test-Connection -Protocol DCOM -ComputerName $b -Count 1 -ErrorAction SilentlyContinue).IPV4Address.IPAddressToString
    If ($nt -ne $null) {$sn = (Get-WmiObject -Class Win32_BIOS -ComputerName $b -Property * -ErrorAction SilentlyContinue).SerialNumber }
    If ($nt -ne $null) {$cs = Get-WmiObject -Class:Win32_ComputerSystem -ComputerName $b -Property * -ErrorAction SilentlyContinue}
    If ($nt -ne $null) {$dt = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).InstallDate.tostring("MM/dd/yyyy")}
    If ($nt -ne $null) {$pr = (Get-WmiObject -ComputerName $b -Class Win32_BIOS -ErrorAction SilentlyContinue); If ($pr -ne $null) {$bd = $pr.ConvertToDateTime($pr.releasedate).ToShortDateString()}}
    If ($sn -eq $null) {$sn = "Not Found"}
    If ($cs -eq $null) {$cs = "Not Found"}
    If ($nt -eq $null) {$nt = "Host Offline"}
    If ($dt -eq $null) {$dt = "Not Found"}
    If ($bd -eq $null) {$bd = "Not Found"}
    #If ($obj -ne $null){$obj = $null}
    [System.Array]$result += New-Object -TypeName PSObject -Property @{
		Computer = $b;
		SerialNumber = $sn;
        Model = $cs.Model;
        Connectivity = $nt;
        OSDate = $dt;
        BIOSDate = $bd;
	}

    $result | Out-Host

}
$result | Export-Csv -Path "$env:USERPROFILE\Desktop\devicelifecyclereport.csv" -Force
