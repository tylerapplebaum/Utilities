function ConvertFrom-UnixEpoch {
<#
.EXAMPLE
Convert-FromUnixEpoch 1000198000

.EXAMPLE
Convert-FromUnixEpoch 1552647118967
#>
[CmdletBinding()]
    param(
		[Parameter(Mandatory, ValueFromPipeline, HelpMessage="Specify the UNIX epoch time")]
		[Alias("t")]
        [string]$EpochTime
	)
	[datetime]$Origin = '1970-01-01 00:00:00'
    If ($EpochTime.length -le 10) { #Seconds case
        $GregorianTime = $Origin.AddSeconds($EpochTime)
    }
    
    ElseIf (($EpochTime.length -gt 10) -and ($EpochTime.length -le 13)) { #Milliseconds case
        Write-Verbose "Assuming millisecond timestamp because $($EpochTime.length) digit timestamp provided"
        $GregorianTime = $Origin.AddMilliSeconds($EpochTime)
    }
    
    ElseIf ($EpochTime.length -eq 16) { #Microseconds case
        Write-Verbose "Assuming usec timestamp because $($EpochTime.length) digit timestamp provided"
        $EpochUsecToMsec = [Math]::Floor([decimal]($EpochTime / 1000))
        $GregorianTime = $Origin.AddMilliSeconds($EpochUsecToMsec)
    }
    Else { #Try it anyway, get an error.
        $GregorianTime = $Origin.AddMilliSeconds($EpochTime)
    }
	Return $GregorianTime
}

function ConvertTo-UnixEpoch {
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