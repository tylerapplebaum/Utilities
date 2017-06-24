$test = [System.Text.Encoding]::UTF8.GetBytes("hello") | %{ [System.Convert]::ToString($_,2).PadLeft(8,'0') }
$key = "00000001"
$bin = $test
$b2 = $bin[0] -bxor $key

$bytes = [System.IO.File]::ReadAllBytes($myFile)
for($i=0; $i -lt $bytes.count ; $i++)
{
    $bytes[$i] = $bytes[$i] -bxor 0x6A #0x^A is the key
}
