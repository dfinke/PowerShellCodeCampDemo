Import-Module .\WPK-Examples\modules\WPK
New-Grid -FontSize 24 -Rows 2 -Columns 2 -On_Loaded {
        Register-PowerShellCommand -name UpdateClock -scriptBlock {
            $stopWatch = $window | Get-ChildControl StopWatch
            $stopWatch.Content = [Datetime]::Now - $stopWatch.Tag
        }
    } {
    New-Label -Name Stopwatch "0:0:0" -ColumnSpan 2 -FontSize 32 -Margin 4
    New-Button -Row 1 -Column 0 S_tart -Margin 4 -On_Click {
        $window |
            Get-ChildControl StopWatch | ForEach-Object {
                $_.Tag = Get-Date
            }
        Start-PowerShellCommand "UpdateClock" -interval ([Timespan]::FromMilliseconds(25))
    }
    New-Button -Row 1 -Column 1 Sto_p -Margin 4 -On_Click {
        Stop-PowerShellCommand -name "UpdateClock"
    }
} -show