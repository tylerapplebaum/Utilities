Function ConvertTo-Base64 {
param(
[CmdletBinding()]
	[Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to encode to base64")]
	[ValidateNotNullOrEmpty()]
    $String
)
Process {
    $StringToByteArr = [System.Text.Encoding]::UTF8.GetBytes($String) #Converts string to byte array
    $Base64String = [System.Convert]::ToBase64String($StringToByteArr) #Converts byte array to b64 string
    Return $Base64String
}
} #End ConvertTo-Base64

Function ConvertFrom-Base64 {
param(
[CmdletBinding()]
    [Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to decode from base64")]
    [ValidateNotNullOrEmpty()]
    $String
)
Process {
    $Base64ToUTF8 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($String)) #Converts b64 string to UTF-8 string
    Return $Base64ToUTF8
}
} #End ConvertFrom-Base64

Function Get-StringHash {
param(
[CmdletBinding()]
    [Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to hash")]
    $String,
    [Parameter(HelpMessage="Hash algorithm")]
    [ValidateSet('MD5','RIPEMD160','SHA1','SHA256','SHA384','SHA512')]
    $Algorithm = "SHA1"
)
Process {
$StringBuilder = New-Object System.Text.StringBuilder
$ByteHash = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) 
	ForEach ($Byte in $ByteHash) {
		[Void]$StringBuilder.Append($Byte.ToString("x2")) #Convert byte array to hex
	}
$Hash = $StringBuilder.ToString()
Return $Hash
}
} #End Get-StringHash

Function Get-URL {
[CmdletBinding()]
param (
	$URL,
	[switch]$Encode
)
[void][Reflection.Assembly]::LoadWithPartialName("System.Web")
$ProcessedURL = [System.Web.HttpUtility]::UrlDecode($URL)
	If ($PSBoundParameters.Encode) {
		$ProcessedURL = [System.Web.HttpUtility]::UrlEncode($URL)
	}
Return $ProcessedURL
} #End Get-URL


Export-ModuleMember ConvertTo-Base64
Export-ModuleMember ConvertFrom-Base64
Export-ModuleMember Get-StringHash
Export-ModuleMember Get-URL
