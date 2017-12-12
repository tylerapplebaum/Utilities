Function Remove-RegistryProperty {
[cmdletbinding()]
Param(
	[string]$RegPath
)

$RegPropToDelete = Get-Item -Path $RegPath | Select-Object -Expand Property
	ForEach ($Property in $RegPropToDelete){
		Write-Verbose "$Property will be removed from $RegPath to prevent profile bloat"
		Remove-ItemProperty -Path $RegPath -Name $Property
	}
} #End Remove-RegistryProperty

Remove-RegistryProperty -RegPath HKCU:\Printers\DevModePerUser -Verbose
Remove-RegistryProperty -RegPath HKCU:\Printers\DevModes2 -Verbose
