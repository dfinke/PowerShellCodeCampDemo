Import-Module .\modules\WPK
ipmo .\modules\OData.psm1 -Force

# check if we are in STA mode. Needed for WPK
if( ((get-host).RunSpace).ApartmentState -ne "sta" ) {
	Write-Host -ForegroundColor Red "Please restart powershell in STA mode (powershell.exe -STA)"
	Return
}

$global:dataServicesFile = ".\ODataServices.csv"

Function Global:Display-Data ($targetObject, $methodName, $window) {

    if(!$methodName) {return}

    $window.Cursor = [System.Windows.Input.Cursors]::Wait

    $window.Title = "Retrieving [$methodName] $(Get-Date)"

    $lvwResults = $window | Get-ChildControl lvwResults
    $items = $targetObject.$methodName.Invoke()

    $spOperations = $window | Get-ChildControl spOperations
    $spOperations.Children.Clear()

    if($items) {
        $lvwResults.DataContext = @($items)
        @($items)[0].GetOperations() | % {
            $spOperations.Children.Add( (New-Button -Content $_ -Margin 3 -On_Click {
                $lvwResults = $window | Get-ChildControl lvwResults
                $methodName = $this.Content
                if($lvwResults.SelectedItem) {
                    Display-Data $lvwResults.SelectedItem $methodName $window
                } else {
                    [Windows.Messagebox]::show("Please select an item from the results area.")
                }
            } ) )
        }

        $global:propertyNames = @($items)[0] | Get-Member -MemberType noteproperty | select -ExpandProperty name
        $lvwResults.View = (& {
            New-GridView -Columns {
                foreach($propertyName in $propertyNames) {
                    New-GridViewColumn $propertyName
                }
            }
        })
    } else {
        [Windows.Messagebox]::show("Sorry, no data was returned")
    }

    $window.Title = "OData PowerShell Explorer"
    $window.Cursor = [System.Windows.Input.Cursors]::Arrow
}

Function Clear-SPOps ($window){
    $spOperations = $window | Get-ChildControl spOperations
    $spOperations.Children.Clear()
}

Function Clear-Results ($window) {
    $lvwResults = $window | Get-ChildControl lvwResults

    $lvwResults.DataContext = $null
    $lvwResults.View = $null
}

Function Global:Display-DataService ($serviceUri, $window) {
    Clear-Results $window
    Clear-SPOps $window

    $lstCollections = $window | Get-ChildControl lstCollections
    $lstCollections.DataContext = $null

    $error.Clear()
    try {
        $global:ODataFeed = New-ODataService $serviceUri
        $lstCollections.DataContext = @(($global:ODataFeed).GetOperations())
        $window.Title = "OData PowerShell Explorer"
    } catch {
        $window.Title = $error[0].Exception.Message
    }
}

Function Global:Do-ServiceUpdate ($control, $script:parentWindow) {

    Function Get-ScreenData ($window) {
        $tbDataServiceName = $window | Get-ChildControl tbDataServiceName
        $tbUrl = $window | Get-ChildControl tbUrl

        New-Object PSObject -Property @{
            Name = $tbDataServiceName.Text
            Uri = $tbUrl.Text
        }
    }

    Function Update-CSVFile ($window) {
        $csv = Import-Csv $global:dataServicesFile
        $csv += (Get-ScreenData $window)
        $csv | Export-Csv $global:dataServicesFile -NoTypeInformation
    }

    Function Global:Do-ReturnKey ($window) {
        Update-CSVFile $window
        $window.Close()
        Get-ODataServices $parentWindow
    }

    Function Global:Do-EscapeKey ($window) {
        $window.Close()
    }

    Function Global:Remove-ODataService ($odataServiceName) {
        $csv = Import-Csv $global:dataServicesFile

        $csv |
            Where {$_.name -ne $odataServiceName} |
                Export-Csv $global:dataServicesFile -NoTypeInformation
    }

    Function Invoke-DataServiceDialog {
        $global:rc = $null
        New-Window -Owner $parentWindow -WindowStartupLocation CenterOwner -SizeToContent WidthAndHeight -Show -On_Loaded {
            ($window | Get-ChildControl tbDataServiceName).Focus()
        } -On_PreviewKeyUp {
            switch ($_.Key) {
                "Return" { Do-ReturnKey $window }
                "Escape" { Do-EscapeKey $window; $global:rc = "escape" }
            }
        } {
            New-Grid -Rows 35, 35, 35 -Columns 75, 100* {
                New-Label -Row 0 -Column 0 "Name" -Margin 5 -HorizontalContentAlignment Right
                New-Label -Row 1 -Column 0 "Url"  -Margin 5 -HorizontalContentAlignment Right

                New-TextBox -Name tbDataServiceName -Row 0 -Column 1 -Margin 5 -Text $dataServiceName
                New-TextBox -Name tbUrl -Row 1 -Column 1 -Margin 5 -Text $url

                New-StackPanel -Row 2 -Column 1 -Orientation Horizontal -HorizontalAlignment Right {
                    New-Button -Name btnOk "_Ok" -Margin 5 -Width 75         -On_Click { Do-ReturnKey $window }
                    New-Button -Name btnCancel "_Cancel" -Margin 5 -Width 75 -On_Click { Do-EscapeKey $window ; $global:rc = "escape" }
                }
            }
        }

        $global:rc
    }

    $lstODataServices = $parentWindow | Get-ChildControl lstODataServices

    switch($control.Name) {
        "btnNew" {
            $script:dataServiceName = ""
            $script:url = ""
            Invoke-DataServiceDialog
        }

        "btnChange" {
            if(!$lstODataServices.SelectedItem) {
                [Windows.Messagebox]::show("Please select a service.")
                return
            }

            $script:dataServiceName = $lstODataServices.SelectedItem.Name
            $script:url =  $lstODataServices.SelectedItem.uri

            $r = Invoke-DataServiceDialog

            if($rc -ne "escape") {
                Remove-ODataService $script:dataServiceName
                Get-ODataServices $parentWindow
            }
        }

        "btnRemove" {
            if(!$lstODataServices.SelectedItem) {
                [Windows.Messagebox]::show("Please select a service.")
                return
            }

            $rc = [Windows.Messagebox]::show("Are you sure you want to remove this service?", "Confirm Delete", "YesNo")

            Remove-ODataService $lstODataServices.SelectedItem.Name
            Get-ODataServices $parentWindow
        }
    }
}

Function Global:Get-ODataServices ($window) {
    $lstODataServices = $window | Get-ChildControl lstODataServices
    $lstODataServices.DataContext = @(Import-Csv $global:dataServicesFile)
}

New-Window -Title "OData PowerShell Explorer" -WindowStartupLocation CenterScreen -Width 1000 -Height 500 -Show -On_Loaded {
    ($window | Get-ChildControl lstCollections).Focus()
    Get-ODataServices $window
} {
    New-Grid -Columns Auto, Auto, Auto, 100* {

        New-GroupBox -Header " OData Services " -Column 0 -Margin 5 {
            New-Grid -Columns 75, Auto {
                $buttonPropeties = @{
                    Height   = 22
                    Margin   = 3
                    On_Click = { Global:Do-ServiceUpdate $this $window }
                }

                New-StackPanel -Column 0 {
                    New-Button -Name btnNew    -Content "_New"    @buttonPropeties
                    New-Button -Name btnChange -Content "_Change" @buttonPropeties
                    New-Button -Name btnRemove -Content "_Remove" @buttonPropeties
                }

                New-ListBox -Column 1 -Name lstODataServices -Margin 5 -DisplayMemberPath Name -DataBinding @{ ItemsSource = New-Binding } -On_SelectionChanged {
                    Display-DataService $this.SelectedItem.uri $window
                }
            }
        }

        New-GroupBox -Header " Collections " -Column 1 -Margin 5 {
            New-ListBox -Name lstCollections -Margin 5 -DataBinding @{ ItemsSource = New-Binding } -On_SelectionChanged {
                Display-Data $global:ODataFeed $this.SelectedItem $window
            }
        }

        New-GroupBox -Header " Drill Down " -Column 2 -Margin 5 { New-StackPanel -Name spOperations }

        New-GroupBox -Header " Results " -Column 3 -Margin 5 {
            New-ListView -Name lvwResults -Margin 5 -DataBinding @{ ItemsSource = New-Binding }
        }
    }
}