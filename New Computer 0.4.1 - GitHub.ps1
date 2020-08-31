#- As Admin Run before executing scripts on new computer
Set-ExecutionPolicy Unrestricted 
#Before executing scripts on new computer

#. Author Chafe Solomon
#Resources 
<#
https://petri.com/add-computer-to-domain-powershell
https://marckean.com/2016/06/01/use-powershell-to-install-windows-updates/
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/rename-computer?view=powershell-7
https://poshgui.com/Editor?Tab=1
https://forums.ivanti.com/s/article/Installing-Microsoft-Office-365-Click-To-Run-Using-The-Office-Deployment-Tool
https://gallery.technet.microsoft.com/scriptcenter/Execute-Windows-Update-fc6acb16
https://www.reddit.com/r/sysadmin/comments/ali1v5/windows_updates_via_powershell/
#>

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}


#Local Admin Account Creation
function CLWINSTALL {   

    #Checks if local user exists
    $AccountAddition = Get-LocalUser clwinstall -ErrorAction SilentlyContinue
    $SerialNumber = (gwmi win32_bios).SerialNumber
    $ComputerName = hostname
    
    $SecurePassword = $SerialNumber | ConvertTo-SecureString -AsPlainText -Force

    #Account Creation
    if(-not ($AccountAddition)){

        #Checks Serial Number and assigns it to the password variable

        Write-Host "Password created..."
        try{
            $ComputerName
            $SerialNumber

            #Creates account and uses the new variable for the password. 
            New-LocalUser -Name 'clwinstall' -Password $SecurePassword -AccountNeverExpires -FullName 'clwinstall' -PasswordNeverExpires -ErrorAction Stop
            Write-Host "Account Created..."
            #Adds the new admin account to the Admin group
            Add-LocalGroupMember -Group 'Administrators' -Member 'clwinstall'
            Write-Host "Account is now Admin..."

        }

        catch{
            Write-Host $Error
                pause
            

        }
        
    }   
    else{
        #If CLW Admin account alread exists.
        $ComputerName
        $SerialNumber
        Set-LocalUser -Name 'clwinstall' -Password $SecurePassword
        Write-Host "CLWINSTALL IS ALREADY ON MACHINE.... Password has been changed to match standard.. Continuing..."
        Start-Sleep(5)
}
}
#Join Domain
function Join_Domain {
    #Rename Computer
    $NewComputerName = $TextBox1.Text

    if ($NewComputerName){
        #Join LOOP Domain
        add-computer -DomainName loop.local -Credential $Creds -Verbose
        Rename-Computer -NewName $NewComputerName -DomainCredential $Creds -Force
        start-sleep(30)
        Restart-Computer -Force

    }
    else{
        write-host "Manually Set Computer Name Then Restart Computer" 
        }

Restart-Computer -Force
}
#Update Windows
function WindowsUpdates {

     #schtasks /create /RU "SYSTEM" /SC MONTHLY /MO THIRD /D WED /M * /RL HIGHEST /TN "Monthly Windows Update Patches" /TR "PowerShell.exe -ExecutionPolicy UnRestricted -File c:\windows\WindowsUpdate_InstallPatches.ps1" /ST 02:00 

     Function WSUSUpdate {

        $Criteria = "IsHidden=0 and IsInstalled=0" #and Type='Software'"
        $Session = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $Session.CreateUpdateSearcher()

            $SearchResult = $UpdateSearcher.Search($Criteria).Updates

            if ($SearchResult.Count -eq 0) {
                #Write-host "There are no applicable updates."
                Write-EventLog -LogName Application -Source "WSH" -Message "There are no applicable updates." -EventId 0 -EntryType information
                #exit
                return $false
            } else {
                    $Downloader = $Session.CreateUpdateDownloader()
                    $Downloader.Updates = $SearchResult
                    $DownloadResult = $Downloader.Download()
                    Write-EventLog -LogName Application -Source "WSH" -Message "Applicable updates found. Setting $($SearchResult.Count) updates to download." -EventId 0 -EntryType information
                    return $true
             }
    }

    Function WSUS-Install {

        $Criteria = "IsHidden=0 and IsInstalled=0" #and Type='Software'"
        $Session = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $Session.CreateUpdateSearcher()

        $WSUSPatchDownloaded = $true

        $SearchResult = $UpdateSearcher.Search($Criteria).Updates


        if ($SearchResult.Count -ne 0) {

            $Downloader = $Session.CreateUpdateDownloader()
            $Downloader.Updates = $SearchResult
            $DownloadResult = $Downloader.Download()

            $i = 0
            Do {
                $i++
                    foreach($Update in $SearchResult) { 
                        if (!($Update.IsDownloaded)) { $WSUSPatchDownloaded = $false } 
                        #write-host $Update.Title
                        if ($Update.IsDownloaded) {
                            #write-host "$($Update.Title) is downloaded"
                            Write-EventLog -LogName Application -Source "WSH" -Message "Update: $($Update.Title) is downloaded and ready to install." -EventId 0 -EntryType information
                        } 
                    }
                    start-sleep -s 60
                } until ($i = 10)

            if (!($WSUSPatchDownloaded)) {

                    $Session = New-Object -ComObject Microsoft.Update.Session
                    $Downloader = $Session.CreateUpdateDownloader()
                    $Downloader.Updates = $SearchResult
                    $DownloadResult = $Downloader.Download()


                    If ($DownloadResult.ResultCode -ne 2) { 
                        #write-host "Problem with download"
                        Write-EventLog -LogName Application -Source "WSH" -Message "There was an unexpected error with the download prior to update install." -EventId 0 -EntryType warning
                    }
             } else {
                    #write-host "Attempting Install"
                    Write-EventLog -LogName Application -Source "WSH" -Message "Attempting to install $($SearchResult.Count) updates." -EventId 0 -EntryType information
                    $Installer = New-Object -ComObject Microsoft.Update.Installer
                    $Installer.Updates = $SearchResult
                    $InstallResult = $Installer.Install()
        
                        If ($InstallResult.ResultCode -ne 0) { 
                            #write-host "Install Result equals: " $InstallResult.ResultCode
                            Write-EventLog -LogName Application -Source "WSH" -Message "Install complete with result code: $($InstallResult.ResultCode) ." -EventId 0 -EntryType information
                        } else {
                            Write-EventLog -LogName Application -Source "WSH" -Message "Install complete with result code: $($InstallResult.ResultCode) ." -EventId 0 -EntryType information
                        }

                        <#If ($InstallResult.rebootRequired) { 
                            Write-EventLog -LogName Application -Source "WSH" -Message "Reboot needed post-patch install, rebooting system." -EventId 0 -EntryType information
                           #$RetVal = Show-PopUp -Message "Reboot needed post-patch install, rebooting system.`n`rPress Cancel to stop the reboot." -Title "Reboot Notification" -TimeOut 20 -ButtonSet OC -Icon Exclamation
                           #If ($RetVal -eq 1 -or $RetVal -eq -1) { Restart-Computer }
                           & c:\windows\system32\shutdown.exe /r /t "60" /c "Rebooting computer for Windows Updates."
                        } else {
                            Write-EventLog -LogName Application -Source "WSH" -Message "Reboot not required post install." -EventId 0 -EntryType information
                        }
                        #>
        
              }
        } else {

        #write-host "No updates found in install phase"

        }
    }

    function Get-StatusValue($value) { 
       switch -exact ($value) {
            0   {"NotStarted"}
            1   {"InProgress"}
            2   {"Succeeded"}
            3   {"SucceededWithErrors"}
            4   {"Failed"}
            5   {"Aborted"}
        }
    }

    $WSUSUpdateStatus = WSUSUpdate

    if ($WSUSUpdateStatus) { 
        WSUS-Install
    }
    elseif (!($WSUSUpdateStatus)) {
        #write-host "No patches needed"
        Write-EventLog -LogName Application -Source "WSH" -Message "No Updates found as needed." -EventId 0 -EntryType information
    }
}

#Software Installation
function Install_Software {
    $O365 = $PSScriptRoot
    $O365 = ($O365 + "\Programs")
    Set-Location $O365
    if ($Apps1.Checked -eq $true){
        Write-Host "Installing Office... "
        Start-Process "setup.exe" -ArgumentList "/configure configuration.xml" -verbose
        Write-Host "Office now Installing... Script will continue in 4mins "
        start-sleep(300)
    }

    if ($Laptop.Checked -eq $true){
        Start-Process -FilePath "AgentInstaller-Non-Tech-Laptop-EN.MSI" -argumentlist "/passive /qn"
        Write-Host "Installing Laptop Vipre..."
        start-sleep(120)
    }

    if ($Desktop.checked -eq $true){
        Start-Process -FilePath "AgentInstaller-Engineer-EN.MSI" -argumentlist "/passive /qn"
        Write-Host "Installing Desktop Vipre..."
        start-sleep(120)
    }

    if ($Apps3.Checked -eq $true){

        Write-Host "Installing Adobe Cloud "
        Set-Location ($O365 + "\Build")
        Start-Process -FilePath "adobe_cc-all_apps-self_serv.msi" -argumentlist "/passive /qn"
        start-sleep(240)
    }

    
    # Google Chrome Installtion
    Write-Host "Installing Chrome "
    Set-Location $O365
    Start-Process -FilePath "Chrome.msi" -ArgumentList "/passive /qn"
    start-sleep(120)
    
    <# Waiting for forticlient config tool. - Max
    if ($Apps2.Checked -eq $true){
    Start-Process -FilePath "Foriclient.msi" -ArgumentList "/passive /qn"
    Write-Host "Installing FortiClient"
    start-sleep(120)
    }
    #>
}
function Set_Lockscreen {
    Write-Host "Updating Group Policy"
    GPUPDATE /FORCE
}
#Main Loop
function main1{
Try{
    if ($Creds){
        Write-Host "Green Light... Starting Script" -ForegroundColor "Green" 
    }

    else{
        Write-Host "Red Light... Closing Script" -ForegroundColor "Red" 
        $Error[0]
        Start-Sleep(10)
        exit
    }

}
Catch{
Write-Host "Credentials not set... closing script..." -ForegroundColor "Red"
exit
}



main1
CLWINSTALL
WindowsUpdates
Install_Software
Join_Domain


}

$Creds = Get-Credential

#New Computer Name GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$eform                           = New-Object system.Windows.Forms.Form
$eform.ClientSize                = New-Object System.Drawing.Point(419,155)
$eform.text                      = " Enter New Computer Name"
$eform.TopMost                   = $false

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 276
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(4,12)
$TextBox1.Font                   = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "START"
$Button1.width                   = 88
$Button1.height                  = 26
$Button1.location                = New-Object System.Drawing.Point(299,11)
$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',12)
$Button1.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#ffffff")
$Button1.Add_Click({$global:NewComputerName = $TextBox1.Text})
$Button1.Add_Click({main1})
$Button1.Add_Click({$eform.close})


$Laptop                          = New-Object system.Windows.Forms.CheckBox
$Laptop.text                     = "Laptop"
$Laptop.AutoSize                 = $false
$Laptop.width                    = 95
$Laptop.height                   = 20
$Laptop.location                 = New-Object System.Drawing.Point(299,48)
$Laptop.Font                     = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Desktop                         = New-Object system.Windows.Forms.CheckBox
$Desktop.text                    = "Desktop"
$Desktop.AutoSize                = $false
$Desktop.width                   = 95
$Desktop.height                  = 20
$Desktop.location                = New-Object System.Drawing.Point(299,68)
$Desktop.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)


$Apps1                           = New-Object system.Windows.Forms.CheckBox
$Apps1.text                      = "Office"
$Apps1.AutoSize                  = $false
$Apps1.width                     = 95
$Apps1.height                    = 20
$Apps1.location                  = New-Object System.Drawing.Point(299,88)
$Apps1.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

<# -- Waiting on Forticlient Config Tool
$Apps2                           = New-Object system.Windows.Forms.CheckBox
$Apps2.text                      = "FortiClient"
$Apps2.AutoSize                  = $false
$Apps2.width                     = 95
$Apps2.height                    = 20
$Apps2.location                  = New-Object System.Drawing.Point(299,108)
$Apps2.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
#>

$Apps3                           = New-Object system.Windows.Forms.CheckBox
$Apps3.text                      = "Creative Cloud"
$Apps3.AutoSize                  = $false
$Apps3.width                     = 115
$Apps3.height                    = 20
#Change this out once you reincorperate Forticlient auto
$Apps3.location                  = New-Object System.Drawing.Point(299,108) 
$Apps3.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$eform.controls.AddRange(@($TextBox1,$Button1,$Laptop,$Desktop,$Apps1,$Apps2,$Apps3))




#Write your logic code here

[void]$eform.ShowDialog()

#Vipre is installed no matter what... It uses the laptop / Desktop to see which version.

# To do
# Install FortiClient


#Finished
# Grab Admin Creds through a Get Creds *
# Prompt for New Computer name *
# Add CLW Install Account *
# Run Windows Updates *
# Install Office *
# Change Computer Name*
# Join Domain -- Restart*