class Person {
    $FirstName
    $LastName    
    [DateTime]$BirthDate

    Person ($FirstName, $LastName, [DateTime]$BirthDate) {
        $this.FirstName = $FirstName
        $this.LastName=$LastName
        $this.BirthDate=$BirthDate
    }
}

cls

[Person]::new("John", "Doe", "2/28/70") | Format-Table -AutoSize