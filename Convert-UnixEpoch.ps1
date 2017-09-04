function Convert-FromUnixEpoch {
<#
.EXAMPLE
Convert-FromUnixEpoch 1000198000
#>
[CmdletBinding()]
    param(
		[Parameter(Mandatory, ValueFromPipeline, HelpMessage="Specify the UNIX epoch time")]
		[Alias("t")]
        [string]$EpochTime
	)
	[datetime]$Origin = '1970-01-01 00:00:00'
	If ($EpochTime.length -le 10) {
		$GregorianTime = $Origin.AddSeconds($EpochTime)
	}
	Else {
		Write-Verbose "Assuming millisecond timestamp"
		$GregorianTime = $Origin.AddMilliSeconds($EpochTime)
	}
	Return $GregorianTime
}

function Convert-ToUnixEpoch {
<#
.EXAMPLE
Convert-ToUnixEpoch $(Get-Date)

.EXAMPLE
Convert-ToUnixEpoch "Tuesday, September 11, 2001 8:46:40 AM"

.EXAMPLE
Convert-ToUnixEpoch "March 5 2018"
#>
[CmdletBinding()]
    param(
		[Parameter(Mandatory,ValueFromPipeline)]
        [datetime]$Time
	)
	[datetime]$Origin = '1970-01-01 00:00:00'
	[Long]$EpochTime = (New-TimeSpan -Start $Origin -End $Time).TotalSeconds
	Return $EpochTime
}