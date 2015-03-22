New-Canvas -Width 640 -Height 480 -On_Loaded {
    $c = $this
    $duration = [Timespan]::FromMilliseconds(200)
    foreach ($n in 1..10) {
        $guid = [GUID]::NewGuid().ToString()
        $window.Resources.TemporaryControls."$guid" = $c

        $popupScript = [ScriptBlock]::Create("
            `$control = `$window.Resources.TemporaryControls.'$guid'
            " + {
                $button = New-Button (1..100 | Get-Random) `
                    -Top (Get-Random -Maximum 240) `
                    -Left (Get-Random -Maximum 320) `
                    -Width 1 -Height 1 -Opacity .01 `
            } + "
            `$null = `$control.Children.Add(`$button)
            " + {
                $button | Move-Control -fadeIn `
                    -Top (Get-Random -Maximum 480) `
                    -Left (Get-Random -Maximum 640) `
                    -Width (Get-Random -Maximum 240) `
                    -Height (Get-Random -Maximum 240) `
                    -Duration ([Timespan]::FromMilliseconds((Get-Random -Minimum 200 -Maximum 500)))
            } + "
            `$window.Resources.TemporaryControls.Remove('$guid')
        ")

        Register-PowerShellCommand `
            -run -once -in ($duration + ([Timespan]::FromMilliseconds(50 * $n))) `
            -scriptBlock $popupScript
    }
} -asJob
