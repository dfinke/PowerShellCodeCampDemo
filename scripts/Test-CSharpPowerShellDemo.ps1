
Add-Type -Path .\CSHarp-PowerShellDemo.dll

$obj = New-Object CSHarp_PowerShellDemo.TestCode

#Use some methods
$x=3
$y=4

$obj.Add($x,$y)
$obj.Multiply(5,6)