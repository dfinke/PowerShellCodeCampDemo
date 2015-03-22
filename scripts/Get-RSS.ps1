Function Get-RSS {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string] $url
    )

    Process {
        foreach($item in @($url)) {
            (Get-Web $item -asXML).rss.channel.item | select @{n="url";e={$item}}, title
        }
    }
}
