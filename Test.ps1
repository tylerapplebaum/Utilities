$test = [System.Text.Encoding]::UTF8.GetBytes("hello") | %{ [System.Convert]::ToString($_,2).PadLeft(8,'0') }
$key = "00000001"
$bin = $test
$b2 = $bin[0] -bxor $key

$bytes = [System.IO.File]::ReadAllBytes($myFile)
for($i=0; $i -lt $bytes.count ; $i++)
{
    $bytes[$i] = $bytes[$i] -bxor 0x6A #0x6A is the key
}
######Base64
#http://ee.hawaii.edu/~tep/EE160/Book/chap4/subsection2.1.1.1.html
#https://stackoverflow.com/questions/8908287/base64-encoding-in-python-3
# https://stackoverflow.com/questions/35334928/convert-base64-string-to-file

[string]$String = "1"



$teststr64 = [System.Text.Encoding]::UTF8.GetBytes($String) | %{ [System.Convert]::ToBase64String($_)} #Converts string to byte array, then b64 array
$fromtest64 = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($teststr64)) #Converts b64string to UTF-8 string
$fromtest64bytes = [System.Text.Encoding]::UTF8.GetBytes([System.Convert]::FromBase64String($testbytes64)) #Converts b64string to byte array
$byteout = [System.Text.Encoding]::UTF8.GetString($fromtest64bytes) #Converts byte array to byte value
$stringout2 = [System.Text.Encoding]::UTF8.GetString($byteout) #Converts byte value back to string

####
Function Get-StringHash {
param(
[CmdletBinding()]
	[Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="String to hash")]
    $String
)
#$Algorithm = ("MD5","RIPEMD160","SHA1","SHA256","SHA384","SHA512")
$Algorithm = "SHA1"
$StringBuilder = New-Object System.Text.StringBuilder
$ByteHash = [System.Security.Cryptography.HashAlgorithm]::Create($Algorithm).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) 
ForEach ($Byte in $ByteHash) {
[Void]$StringBuilder.Append($Byte.ToString("x2")) #Convert byte array to hex
}
$Hash = $StringBuilder.ToString()
Return $Hash
}
#https://msdn.microsoft.com/en-us/library/aa311428(v=vs.71).aspx
1 | Get-StringHash
Measure-Command -Expression { 1 | Get-StringHash }
Trace-Command -Name CommandDiscovery -Expression { 1 | Get-StringHash } -PSHost
Trace-Command -Name ParameterBinding -Expression { 1 | Get-StringHash } -PSHost
Set-PSDebug -Trace 1
1 | Get-StringHash
###########################
#Compress
$InputString = @"
YourInputHere
"@
$MemoryStream = New-Object System.IO.MemoryStream
$CompressionStream = New-Object System.IO.Compression.GZipStream($MemoryStream, [System.IO.Compression.CompressionMode]::Compress)
$StreamWriter = New-Object System.IO.StreamWriter($CompressionStream)
$StreamWriter.Write($InputString)
$StreamWriter.Close()
$s = [System.Convert]::ToBase64String($MemoryStream.ToArray())

#Decompress
#http://learningpcs.blogspot.com/2011/08/powershell-converting-joel-bennetts.html
$data = [System.Convert]::FromBase64String($s)
$ms = New-Object System.IO.MemoryStream
$ms.Write($data, 0, $data.Length)
$ms.Seek(0,0) | Out-Null
$cs = New-Object System.IO.StreamReader(New-Object System.IO.Compression.GZipStream($ms, [System.IO.Compression.CompressionMode]::Decompress))

$sr = New-Object System.IO.StreamReader($cs)
$t = $sr.readtoend()
$cs.Close()