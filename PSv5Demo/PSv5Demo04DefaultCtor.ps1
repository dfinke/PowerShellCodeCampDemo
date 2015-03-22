class Person {
    $FirstName
    $LastName    
    [DateTime]$BirthDate

    Person () {}
}

cls

$h = @{
    FirstName = "Jane"
    LastName  = "Doe"
    BirthDate = "2/28/77"
}

[Person]$h | Format-Table -AutoSize