Function Get-OData {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string] $url
    )

    Process {
        foreach($item in @($url)) {
            (Get-Web $item -asXML).Service.workspace.collection | select @{n="url";e={$item}}, title
        }
    }
}