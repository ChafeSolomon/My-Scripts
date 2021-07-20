#Written by Chafe Solomon

$ErrorActionPreference= 'silentlycontinue'
$User = $env:UserName
Write-Host "The Current User is $User"

start "C:\Users\$User\AppData\Local\Google\Chrome"
Function RenameProfile{
    #Close All Chrome Browsers
    Stop-Process -Name "Chrome"
    Write-Host "Renaming profile and swapping"
    cd "C:\Users\$User\AppData\Local\Google\Chrome"
    #Rename Chrome profile to .old
    Rename-item "User Data" -NewName "User Data.old"
    #Boot Chrome 
    Start "Chrome"
    #Include Revert Option and GUI
}
Function RevertProfile{
    #Close All Chrome Browsers
    Stop-Process -Name "Chrome" 
    
    Write-Host "Restoring profile to original state"
    cd "C:\Users\$User\AppData\Local\Google\Chrome"
    #Rename Chrome profile to .old
    Remove-item "User Data" -Recurse -Force -Confirm:$false
    Rename-item "User Data.old" -NewName "User Data" 
    start "chrome"
    #Boot Chrome 
    
}


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Title                           = New-Object system.Windows.Forms.Form
$Title.ClientSize                = New-Object System.Drawing.Point(337,102)
$Title.text                      = "Chrome Worker"
$Title.TopMost                   = $false
$Title.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("#bebebe")

$Remove                          = New-Object system.Windows.Forms.Button
$Remove.text                     = "Recreate Profile"
$Remove.width                    = 171
$Remove.height                   = 30
$Remove.location                 = New-Object System.Drawing.Point(12,9)
$Remove.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Remove.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#d0d0d0")
$Remove.Add_Click({RenameProfile})

$Revert                          = New-Object system.Windows.Forms.Button
$Revert.text                     = "Revert"
$Revert.width                    = 171
$Revert.height                   = 30
$Revert.location                 = New-Object System.Drawing.Point(12,59)
$Revert.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$Revert.BackColor                = [System.Drawing.ColorTranslator]::FromHtml("#c3c3c3")
$Revert.Add_Click({RevertProfile})

$Title.controls.AddRange(@($Remove,$Revert))




#Write your logic code here

[void]$Title.ShowDialog()