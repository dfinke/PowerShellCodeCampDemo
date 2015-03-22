# From the System.Net namespace
$wc   = New-Object Net.WebClient
$rss  = $wc.DownloadString("http://blogs.msdn.com/b/powershell/atom.aspx")
$feed = [xml]$rss 

$feed.feed.entry| % title