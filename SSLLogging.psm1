#https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/

Function Register-SSLLogging {
[CmdletBinding()]
    param(
        [Parameter(HelpMessage="SSL key file log path")]
        [string]$SSLPath = "C:\Temp\SSLLog.txt"
	)
	[Environment]::SetEnvironmentVariable("SSLKEYLOGFILE", $SSLPath,"Machine")
}

Function Unregister-SSLLogging {
	[Environment]::SetEnvironmentVariable("SSLKEYLOGFILE",$null,"Machine")
}

Function Set-WiresharkPreferences {
	[CmdletBinding()]
    param(
        [Parameter(HelpMessage="Wireshark preferences file path")]
        [string]$WiresharkPrefsPath = "C:\Users\$env:username\AppData\Roaming\Wireshark\preferences2",
		
		[Parameter(HelpMessage="SSL key file log path")]
        [string]$SSLPath = "C:\Temp\SSLLog.txt"
	)
	If (($Preferences = Get-Content $WiresharkPrefsPath) -notlike $null) {
		$Preferences | ForEach-Object {$_ -Replace "#ssl.keylog_file:","ssl.keylog_file: $SSLPath"} | Set-Content $WiresharkPrefsPath
	}
	Else {
		Write-Error -Exception ([System.IO.FileNotFoundException]::new("Could not find path: $SSLPath")) -ErrorAction Stop
	}
	If (((Get-Content $WiresharkPrefsPath) | Select-String -Pattern "$SSLPath" -SimpleMatch) -notlike $null) {
		Write-Verbose "Wireshark config file updated"
	}
	Else {
		Write-Error -Message "Wireshark config file not updated"
	}
}

Export-ModuleMember Register-SSLLogging
Export-ModuleMember Unregister-SSLLogging
Export-ModuleMember Set-WiresharkPreferences