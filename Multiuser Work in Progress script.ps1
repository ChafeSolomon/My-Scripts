#  Requirements Two sets of CSV's to import that have different attributes to replace. 
$UserDatacsv = "C:\users\admin-csolomon\Desktop\Imports\Import.csv
$SiteSpecificCSVp = "C:\users\admin-csolomon\Desktop\adautomation\AttributeData\SiteSpecificAttributes.csv"


 

# Change Managers - Run ForEach loop from CSV to pull names and managers and change them out. 

$UserData = Import-Csv -Path $UserDatacsv
try{
foreach ($User in $UserData){
Get-ADUser $User.User -Properties Description, Office | Set-ADUser -Description $User.Description -Title $User.Description -Division $User.Division -Manager $User.Manager

}

#-- Location Change If statement that requires confirmation to pull different areas. 
}

catch{}

$SiteSpecificCSV = Import-Csv $SiteSpecificCSVp #!-- Could this be done when $UserData is imported? 


     

$Company = "COMPANY NAME"
    foreach ($User in $UserData){
    #assign location attribute variables based on users location
    $Office = $User.Office
    if ($Office){ 
    $UserSite = $SiteSpecificCSV | Where-Object {$_.Office -eq $Office}
    $OU = $UserSite.UserOU
$City = $UserSite.City
$StreetAddress = $UserSite.StreetAddress
$State = $UserSite.State
$PostalCode = $UserSite.PostalCode
$c = $UserSite.C
$co = $UserSite.Co
$countrycode = $UserSite.CountryCode
$preferredlanguage = $UserSite.preferredlanguage

    Get-ADUser -Identity $User.User | Set-ADUser -Office $Office -City $City -StreetAddress $StreetAddress `
                -State $State -PostalCode $PostalCode -Replace @{c = $c; co = $co; `
                    countrycode = $countrycode; preferredlanguage = $preferredlanguage   }
                    
                    }
                    else{ Write-Host $User.User "doesnt have Office set"
                    pause
                    }

                    pause

}


foreach ($User in $UserData){
Get-ADUser $User.User -Properties Description, Office, Manager }
