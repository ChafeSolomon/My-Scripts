<#  Author.
    Chafe Solomon

    All Documentation for Papercut Sync is found here:
    https://www.papercut.com/support/resources/manuals/ng-mf/common/topics/tools-server-command.html
    https://www.papercut.com/kb/Main/CallingServerCommandRemotely
    https://docs.microsoft.com/en-us/sysinternals/downloads/psexec

    GUI Information provided by POSHGUI


#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Window                          = New-Object system.Windows.Forms.Form
$Window.ClientSize               = '616,293'
$Window.text                     = "Badge Updater"
$Window.TopMost                  = $false

#Query for user information
function userinfo {
$User = $TextBox1.text;
$NewNumber = $TextBox2.text;
if ($User) {
$Output1 = Get-ADUser -Filter {sAMAccountName -eq $User } -Properties Name,extensionattribute1 | Select-Object Name, extensionattribute1 
$outputBox.text = $Output1 |
Format-Table -Property Name, extensionattribute1 -AutoSize -hidetableheaders | Out-String 

    if ($UpdateID.checked -eq $true -and $TextBox2.text){
    Set-ADUser -Identity $User -Replace @{extensionAttribute1 = $NewNumber; extensionAttribute2 =$NewNumber} -Verbose
    $Output1 = Get-ADUser -Filter {sAMAccountName -eq $User } -Properties Name,extensionattribute1 | Select Name,extensionAttribute1
    $outputBox.text = $Output1   |
Format-Table -Property Name, extensionattribute1 -AutoSize -hidetableheaders | Out-String 

    
}
}
    
else {
$Output2 = "Please insert Username"
$OutputBox.text = $Output2


}
}

#Paper Cut Sync
function PaperCutSync {

# Initiate Session with Papercut server and push command to force sync
C:\PsExec\psexec.exe \\idc-vm-prtmgmt.ennisflint.com "C:\Program Files\PaperCut MF\server\bin\win\server-command.exe" perform-user-and-group-sync



}

#Checkbox
$UpdateID                        = New-Object system.Windows.Forms.CheckBox
$UpdateID.text                   = "Update Badge ID"
$UpdateID.AutoSize               = $false
$UpdateID.width                  = 104
$UpdateID.height                 = 20
$UpdateID.location               = New-Object System.Drawing.Point(270,95)
$UpdateID.Font                   = 'Microsoft Sans Serif,9'
$UpdateID.checked                
$Window.Controls.Add($UpdateID)

#Search Username
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 346
$TextBox1.height                 = 100
$TextBox1.location               = New-Object System.Drawing.Point(24,40)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'
$TextBox1.Add_TextChanged({
    $this.Text = $this.Text -replace '[0-9]'
    })
$Window.Controls.Add($TextBox1)

#Badge ID
$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 218
$TextBox2.height                 = 20
$TextBox2.location               = New-Object System.Drawing.Point(24,90)
$TextBox2.Font                   = 'Microsoft Sans Serif,10'
$TextBox2.MaxLength = 5
# Added code...
$TextBox2.Add_TextChanged({
    $this.Text = $this.Text -replace '\D'
    })
$Window.Controls.Add($TextBox2)

#Search Button
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "Search / Update"
$Button1.width                   = 155
$Button1.height                  = 30
$Button1.location                = New-Object System.Drawing.Point(433,241)
$Button1.Font                    = 'Microsoft Sans Serif,10'
$Button1.Add_Click({userinfo})
$Window.Controls.Add($Button1)

$Button2                         = New-Object system.Windows.Forms.Button
$Button2.BackColor               = 'LightGreen'
$Button2.text                    = "Sync with PaperCut"
$Button2.width                   = 100
$Button2.height                  = 100
$Button2.location                = New-Object System.Drawing.Point(30,150)
$Button2.Font                    = 'Microsoft Sans Serif,10'
$Button2.Add_Click({PaperCutSync})
$Window.Controls.Add($Button2)

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Search Username: " 
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(24,20)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Badge Replacment ID: "
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(24,70)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "User Information"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(436,27)
$Label3.Font                     = 'Microsoft Sans Serif,10'

#Results
$outputBox                       = New-Object System.Windows.Forms.TextBox 
$outputBox.Location              = New-Object System.Drawing.Size(433,43)
$outputBox.Size                  = New-Object System.Drawing.Size(170,180) 
$outputBox.MultiLine             = $True 
$outputBox.ScrollBars            = "Vertical"
$outputBox.ReadOnly              = $True
$Window.Controls.Add($outputBox)

$Window.controls.AddRange(@($UpdateID,$outputBox,$TextBox1,$TextBox2,$Button1,$Button2,$Label1,$Label2,$Label3))


[void]$Window.ShowDialog()

