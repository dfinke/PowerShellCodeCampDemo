class Person {
    $FirstName
    $LastName    
    [DateTime]$BirthDate
}

cls

$p = [Person]::new() 

$p.FirstName = "John"
$p.LastName  = "Doe"
$p.BirthDate = "2/28/70"

$p | Format-Table -AutoSize