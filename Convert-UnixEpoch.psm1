Function ConvertFrom-UnixEpoch {
<#
.EXAMPLE
ConvertFrom-UnixEpoch 1000198000

.EXAMPLE
ConvertFrom-UnixEpoch 1552647118967
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
        $EpochUsecToMsec = [Math]::Floor([decimal]($EpochTime / 1000)) #Convert to milliseconds, round down any decimal
        $GregorianTime = $Origin.AddMilliSeconds($EpochUsecToMsec)
    }
    Else { #Try it anyway, get an error.
        $GregorianTime = $Origin.AddMilliSeconds($EpochTime)
    }
    Return $GregorianTime
}

Function ConvertTo-UnixEpoch {
<#
.EXAMPLE
ConvertTo-UnixEpoch $(Get-Date)

.EXAMPLE
ConvertTo-UnixEpoch "Tuesday, September 11, 2001 8:46:40 AM"

.EXAMPLE
ConvertTo-UnixEpoch "March 5 2018"
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
