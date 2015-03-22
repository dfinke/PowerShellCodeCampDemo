# alternative to XML sytax
Function New-TodoList($name, $code) {

	Function New-Task ($priority, $taskName) {
		New-Object PSObject -Property @{
			Name     = $name
			Priority = $priority
			TaskName = $taskName
		} | Select Name, Priority, TaskName
	}

	& $code
}