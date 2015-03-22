New-TodoList housework {
	New-Task high   "Clean the house."
	New-Task medium "Wash the dishes."
	New-Task medium "Buy more soap."

	"Buy Beer", "Sell Apple stock", "Take a nap" | ForEach {
		New-Task high $_
	}
}