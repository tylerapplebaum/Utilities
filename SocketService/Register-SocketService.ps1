Function script:Register-SocketService {
	[CmdletBinding()]
		param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[String]$ServiceName = "SocketService",

		[Parameter(ValueFromPipeline)]
		[String]$BinPath = "C:\Users\User\Documents\GitHub\Utilities\SocketService\SocketService.exe"
		)
		$BinCertProperties = Get-AuthenticodeSignature $BinPath
		
		If ($BinCertProperties.Status -Notlike "Valid") {
			$Confirm = $True
			Write-Warning "$ServiceName is not signed with a valid certificate"
		}
		
		New-Service -Name $ServiceName -BinaryPathName $BinPath -DisplayName $ServiceName -Description "Asynchronous socket listening on TCP/27015" -StartupType Automatic -Verbose -Confirm $True
		
		If (!(Test-Path C:\Temp)){
			New-Item -ItemType Directory -Path C:\ -Name Temp | Out-Null #Make the log path for the service log
		}
}

. Register-SocketService