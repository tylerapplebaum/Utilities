$Subject = "Tyler Applebaum PowerShell Code Signing Cert"
$EMail = "tylerapplebaum@gmail.com"
$SubjectFull = "CN=$Subject,E=$EMail"
$FriendlyName = "PSCodeSigning"
$BinPath = "SocketService2.exe"

$Password = "1234" | ConvertTo-SecureString -AsPlainText -Force
$CertFilePath = $([Environment]::GetFolderPath("Desktop"))
$CertValidYears = 5

Function script:Get-TimeStampServer {
	[CmdletBinding()]
		param(
		[Parameter(ValueFromPipeline=$True)]
		$TimeStampServers = @("http://timestamp.globalsign.com/scripts/timstamp.dll","http://ca.signfiles.com/tsa/get.aspx"),
		[Parameter(ValueFromPipeline=$False)]
		$Servers = (New-Object System.Collections.Generic.List[System.String])
		)
	ForEach ($Server in $TimeStampServers) {
		$ServerName = $Server -Replace("^http:\/\/","") -Replace ("\/.*","") #Isolate hostnames for Test-Connetion
		Write-Verbose $ServerName
		$Servers.Add($ServerName)
	}

	If (Test-Connection $Servers[0] -Count 1 -Quiet) {
		$TimeStampServer = $TimeStampServers[0]
		Write-Verbose "$($TimeStampServers[0]) selected"
	}

	Elseif ($TimeStampServer -eq $Null) {
		Test-Connection $Servers[1] -Count 1 -Quiet
		$TimeStampServer = $TimeStampServers[1]
		Write-Verbose "$($TimeStampServers[1]) selected"
	}

	Else {
		Write-Verbose "No timestamp servers available"
	}
}
$CodeSigningCert = New-SelfSignedCertificate -Type CodeSigningCert -KeyUsage DigitalSignature -KeyAlgorithm RSA -CertStoreLocation "Cert:\CurrentUser\My" -Subject $SubjectFull -NotAfter $(Get-Date).AddYears($CertValidYears) -FriendlyName $FriendlyName

Export-PfxCertificate -Cert $CodeSigningCert -Password $Password -FilePath $CertFilePath\$FriendlyName.pfx

#Install cert in root store so it is trusted

Import-PfxCertificate -FilePath $CertFilePath\$FriendlyName.pfx -CertStoreLocation "Cert:\LocalMachine\Root\"
#Use if new cert not generated
#$CodeSigningCert = Get-ChildItem Cert:\CurrentUser\My | Where-Object FriendlyName -like $FriendlyName

Set-AuthenticodeSignature -FilePath $BinPath -Certificate $CodeSigningCert[0] -TimestampServer $TimeStampServer -HashAlgorithm SHA256

Get-AuthenticodeSignature -FilePath $BinPath