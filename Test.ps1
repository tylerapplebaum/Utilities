########UNIX datetime bs
[DateTimeOffset]::FromUnixTimeSeconds(1111000011) | Select -ExpandProperty DateTime
######

$test = [System.Text.Encoding]::UTF8.GetBytes("hello") | %{ [System.Convert]::ToString($_,2).PadLeft(8,'0') } #Ensure you have an 8-bit byte... not a 7-bit bizzle
$key = "00000001"
$bin = $test
$b2 = $bin[0] -bxor $key

$bytes = [System.IO.File]::ReadAllBytes($myFile)
for($i=0; $i -lt $bytes.count ; $i++) {
    $bytes[$i] = $bytes[$i] -bxor 0x6A #0x6A is the key
}
######Base64
#http://ee.hawaii.edu/~tep/EE160/Book/chap4/subsection2.1.1.1.html
#https://stackoverflow.com/questions/8908287/base64-encoding-in-python-3
# https://stackoverflow.com/questions/35334928/convert-base64-string-to-file

Function ConvertTo-Base64 {
param(
[CmdletBinding()]
	[Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to encode to base64")]
	[ValidateNotNullOrEmpty()]
    $String
)
$StringToByteArr = [System.Text.Encoding]::UTF8.GetBytes($String) #Converts string to byte array
$Base64String = [System.Convert]::ToBase64String($StringToByteArr) #Converts byte array to b64 string

Return $Base64String
} #End Convert-ToBase64

Function ConvertFrom-Base64 {
param(
[CmdletBinding()]
	[Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to decode from base64")]
	[ValidateNotNullOrEmpty()]
    $String
)
$Base64ToUTF8 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($String)) #Converts b64 string to UTF-8 string

Return $Base64ToUTF8
}
####

Function Get-StringHash {
param(
[CmdletBinding()]
	[Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to hash")]
    $String,
	[Parameter(HelpMessage="Hash algorithm")]
	[ValidateSet('MD5','RIPEMD160','SHA1','SHA256','SHA384','SHA512')]
	$Algorithm = "SHA1"
)
$StringBuilder = New-Object System.Text.StringBuilder
$ByteHash = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) 
	ForEach ($Byte in $ByteHash) {
		[Void]$StringBuilder.Append($Byte.ToString("x2")) #Convert byte array to hex
	}
$Hash = $StringBuilder.ToString()
Return $Hash
} #End Get-StringHash

####

Function ConvertTo-GZip {
#Compress
$InputString = @"
YourInputHere2
"@
$MemoryStream = New-Object System.IO.MemoryStream
$CompressionStream = New-Object System.IO.Compression.GZipStream($MemoryStream, [System.IO.Compression.CompressionMode]::Compress)
$StreamWriter = New-Object System.IO.StreamWriter($CompressionStream)
$StreamWriter.Write($InputString)
$StreamWriter.Close()
$GZip = [System.Convert]::ToBase64String($MemoryStream.ToArray())
}

Function ConvertFrom-GZip {
#Decompress
$data = [System.Convert]::FromBase64String($GZIP)
$ms = New-Object System.IO.MemoryStream
$ms.Write($data, 0, $data.Length)
$ms.Seek(0,0) | Out-Null
$sr = New-Object System.IO.StreamReader(New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress))
$sr.readtoend()
$sr.close()
}



####### Misc and debugging
#https://msdn.microsoft.com/en-us/library/aa311428(v=vs.71).aspx
1 | Get-StringHash
Measure-Command -Expression { 1 | Get-StringHash }
Trace-Command -Name CommandDiscovery -Expression { 1 | Get-StringHash } -PSHost
Trace-Command -Name ParameterBinding -Expression { 1 | Get-StringHash } -PSHost
Set-PSDebug -Trace 1
1 | Get-StringHash
###########################