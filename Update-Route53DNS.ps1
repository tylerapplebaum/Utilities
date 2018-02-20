Function script:Set-Environment {
#https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html
#https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html
[CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True,HelpMessage="Specify the module to attempt to load")]
		[string]$ModuleName,
		
		[Parameter(Mandatory=$True,HelpMessage="Specify the AWS credential profile")]
		[string]$AWSProfileName,
		
		[Parameter(Mandatory=$True,HelpMessage="Specify the AWS region to connect to")]
		[string]$AWSRegion
	)
	
	Try {
		Import-Module -Name $ModuleName -ErrorAction Stop
	}
	Catch [Exception] {
		Return $_.Exception.Message
	}
	
	If ((Get-AWSCredential -ProfileName $AWSProfileName) -like $Null) {
		Write-Error "Run Set-AWSCredential to set up your profile"
	}
	
	Initialize-AWSDefaultConfiguration -ProfileName $AWSProfileName -Region $AWSRegion
} #End Set-Environment

Function script:Get-PublicIPv4Address {
#https://ipinfo.io/developers
[CmdletBinding()]
    param(
	    [Parameter(HelpMessage="Specify the URL to query")]
		[string]$IPInfoURL = "ipinfo.io/json"
	)
	$IPInfo = Invoke-WebRequest $IPInfoURL
	If ($IPInfo -notlike $null) {
		$IPObject = ConvertFrom-Json $IPInfo.Content
		$IPAddr = $IPObject.ip
		Write-Verbose "Current public IP is $IPAddr"
	}
	Else {
		Write-Error "No content found in web response from $IPInfoURL"
	}
} #End Get-PublicIPv4Address

Function script:Get-Route53DNSRecord {
[CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True,HelpMessage="Specify the domain to query")]
		[string]$DomainToGet,
		
		[Parameter(Mandatory=$True,HelpMessage="Specify the record to query")]
		[string]$RecordToGet
	)
	
	$HostedZoneId = Get-R53HostedZonesByName -DNSName $DomainToGet | Select-Object -ExpandProperty Id
	$R53ResourceRecordSets = (Get-R53ResourceRecordSet -HostedZoneId $HostedZoneId).ResourceRecordSets
	$RecordToGetResourceRecord = $R53ResourceRecordSets | Where-Object Name -like "*$RecordToGet*" | Select-Object -ExpandProperty ResourceRecords
	$RecordToGetValue = $RecordToGetResourceRecord | Select-Object -ExpandProperty Value
	Write-Verbose "Current A record value for $RecordToGet.$DomainToGet is $RecordToGetValue"
} #End Get-Route53DNSRecord

Function script:Set-Route53DNSRecord {
[CmdletBinding()]
    param(
	    [Parameter(HelpMessage="Specify the domain to work in")]
		[string]$DomainToSet,
		
		[Parameter(Mandatory=$True,HelpMessage="Specify the record to set")]
		[string]$RecordToSet,
		
		[Parameter(Mandatory=$True,HelpMessage="Specify the record type to set")]
		[string]$RecordType,

		[Parameter(Mandatory=$True,HelpMessage="Specify the record TTL")]
		[int]$TTL
	)
	
	#$ResourceName = $RecordToSet + "." + $DomainToSet
	$ResourceRecordSet = New-Object Amazon.Route53.Model.ResourceRecordSet -Property @{
		"Name" = $RecordToSet + "." + $DomainToSet
		"Type" = $RecordType
		"ResourceRecords" = $(New-Object Amazon.Route53.Model.ResourceRecord($IPAddr))
		"TTL" = $TTL
	}
	$Action = [Amazon.Route53.ChangeAction]::UPSERT
	$Change = New-Object Amazon.Route53.Model.Change ($Action, $ResourceRecordSet)
	$Route53Change = Edit-R53ResourceRecordSet -HostedZoneId $HostedZoneId -ChangeBatch_Change $Change
	
	Write-Output $Route53Change
	<#
	Do {
		If ($GetRoute53Change.Status.Value -eq 'INSYNC') {
			Break
			Write-Output "Change status is now $($GetRoute53Change.Status.Value)"
		}
		Else {
			Start-Sleep -Milliseconds 500
			$GetRoute53Change = Get-R53Change -Id $Route53Change.Id
			Write-Output "Change status is $($GetRoute53Change.Status.Value)"
		}
	}
	While ($GetRoute53Change.Status.Value -ne 'INSYNC')
		
	
	$GetRoute53Change = Get-R53Change -Id $Route53Change.Id
	While (!($GetRoute53Change.Status.Value -eq 'INSYNC')) {
		Start-Sleep -Milliseconds 500
		$GetRoute53Change = Get-R53Change -Id $Route53Change.Id
		Write-Output "Change status is $($GetRoute53Change.Status.Value)"
	}
	#>
} #End Set-Route53DNSRecord

. Get-PublicIPv4Address -Verbose

. Set-Environment -ModuleName AWSPowerShell -AWSProfileName powershell-api -AWSRegion us-west-2

. Get-Route53DNSRecord -DomainToGet linuxabuser.com -RecordToGet emby -Verbose

If ($RecordToGetValue -ne $IPAddr) {
	Set-Route53DNSRecord -DomainToSet linuxabuser.com -RecordToSet emby -RecordType A -TTL 300
}

#https://gist.github.com/guitarrapc/76355bdb8223612431b1