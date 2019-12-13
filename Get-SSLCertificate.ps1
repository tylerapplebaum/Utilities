#Forked from https://github.com/JustinGrote/Scripts/blob/master/Get-SSLCertificate.ps1

Function Get-SSLCertificate {
[CmdletBinding()]
param(
        [parameter(Mandatory,ValueFromPipeline)][string[]]$ComputerName,
        [int]$Port=443,
        [int]$Timeoutms=3000
)


process { 
    ForEach ($Computer in $ComputerName) {
    Write-Verbose "$computer`: Connecting on port $Port"
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $Req = [Net.HttpWebRequest]::Create("https://$computer`:$port/")
    $Req.Timeout = $Timeoutms
    
    Try {
        $Req.GetResponse() | Out-Null
    } Catch {
        Write-Error "Couldn't connect to $Computer on port $Port - $($Error[0].Exception.Message)"
        Continue
    }
    
    If (!($req.ServicePoint.Certificate)) {
        Write-Error "No Certificate returned from $Computer"
        Continue
    }
    
    $CertInfo = $Req.ServicePoint.Certificate

    $Returnobj = [ordered]@{
        ComputerName = $Computer
        Port = $Port
        Subject = $CertInfo.Subject
        Thumbprint = $CertInfo.GetCertHashString()
        Issuer = $Certinfo.Issuer
        SerialNumber = $Certinfo.GetSerialNumberString()
        Issued = [DateTime]$Certinfo.GetEffectiveDateString()
        Expires = [DateTime]$Certinfo.GetExpirationDateString();
        DaysTilExp = New-TimeSpan $(Get-Date) $([DateTime]$Certinfo.GetExpirationDateString();) | Select-Object -ExpandProperty Days
    }

    New-Object PSCustomObject -Property $Returnobj
    } 
}
} #End Get-SSLCertificate
