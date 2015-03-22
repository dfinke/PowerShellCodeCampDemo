Function Get-Web {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [string] $url,
        [switch] $asXML
    )
    
    Begin { $wc = New-Object Net.WebClient }
    
    Process {
        @($url) | ForEach {
            
            $result = $wc.DownloadString($_)
            
            if($asXML) { [xml] $result } 
            else       { $result }
        }
    }
}