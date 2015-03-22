class Person {
    $FirstName
    $LastName    
    [DateTime]$BirthDate

    Person ($FirstName, $LastName, [DateTime]$BirthDate) {
        $this.FirstName = $FirstName
        $this.LastName=$LastName
        $this.BirthDate=$BirthDate
    }

    Details() {
        $result = "{0}, {1} : {2}" -f $this.LastName, $this.FirstName, $this.BirthDate.ToString("d") 
       
        $result | Out-Host
    }
}

cls
$(
    [Person]::new("John", "Doe", "2/28/70")
    [Person]::new("Jane", "Doe", "3/28/80")
    [Person]::new("Hank", "Doe", "4/28/90")
) | ForEach Details