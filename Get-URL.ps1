Function Get-URL {
[CmdletBinding()]
param (
	[string]$URL,
	[switch]$Encode
)
[void][Reflection.Assembly]::LoadWithPartialName("System.Web")
$ProcessedURL = [System.Web.HttpUtility]::UrlDecode($URL)
	If ($PSBoundParameters.Encode) {
		$ProcessedURL = [System.Web.HttpUtility]::UrlEncode($URL)
	}
Return $ProcessedURL
}
