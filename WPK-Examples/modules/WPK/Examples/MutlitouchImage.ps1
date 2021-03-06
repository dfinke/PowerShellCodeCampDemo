New-Window -Background Black -WindowState Maximized -Resource @{
    Styluses=@{}
} -On_Loaded {
    $this | 
        Enable-MultiTouch
    $c = 0
    $path =  'C:\Users\Public\Videos\Sample Videos'
    #$path = "$env:UserProfile\Pictures"
    Get-ChildItem $path | 
        Get-Random -Count 4 |  
        ForEach-Object {
            New-MediaElement -LoadedBehavior Manual -On_Loaded {
                $this.Play()
            } -On_MediaEnded {
                $this.Position = 0
                $this.Play()
            } -Name "Image$c" -Top (Get-Random -Maximum 800) -left (Get-Random -Maximum 1000) `
                -Source $_.FullName -Width 300 -Height 200 -Stretch Fill -Visibility Collapsed
            $c++
        } |
        Add-ChildControl -parent $this.Content -passThru | 
        ForEach-Object {
            $this.Resources.($_.Name) = $_
        }
} -On_StylusDown {
    $image = $this.Resources."Image$($_.StylusDevice.ID - 10)" 
    if ($image) {
        $image.Visibility = "Visible"
        $image.SetValue([Windows.Controls.Canvas]::TopProperty, ($origin.Y - 100) -as [Double])
        $image.SetValue([Windows.Controls.Canvas]::LeftProperty, ($origin.X - 100) -as [Double])
        $animation = New-DoubleAnimation -From 300 -To 3000 -Duration (New-TimeSpan -Seconds 5)    
        Start-Animation -inputObject $image -property Width -animation $animation
        $animation = New-DoubleAnimation -From 200 -To 2000 -Duration (New-TimeSpan -Seconds 5)    
        Start-Animation -inputObject $image -property Height -animation $animation
    } 
} -On_StylusMove {
    $origin = $_.GetPosition($this.Content)    
    $image = $this.Resources."Image$($_.StylusDevice.ID - 10)" 
    if ($image) {
        $image.SetValue([Windows.Controls.Canvas]::TopProperty, ($origin.Y - 100) -as [Double])
        $image.SetValue([Windows.Controls.Canvas]::LeftProperty, ($origin.X - 100) -as [Double])
    } 
} -On_StylusUp {
    $origin = $_.GetPosition($this.Content)    
    $image = $this.Resources."Image$($_.StylusDevice.ID - 10)" 
    if ($image) {
        $image.Visibility = "Collapsed"
        $image.SetValue([Windows.Controls.Canvas]::TopProperty, $origin.Y - 100)
        $image.SetValue([Windows.Controls.Canvas]::LeftProperty, $origin.X - 100)
        $image.Width = 300
        $image.Height = 200
    } 
} {
    New-Canvas 
} -Show