#Var
$CSV = Import-Csv -Path "C:\Users\csolomon\Documents\Imports1.csv"
$CSVf = $CSV.Folders
$CSVs = $CSV.Subfolders

#For each loop to replce the * for a - so that it can follow proper directory naming
Foreach($Object in $CSVf){
    $NewDirectory = $Object.replace("*","-")
    $NewDirectory = '/' + $NewDirectory +'/'

#Add subfolders to the main folder directory
    Foreach($Object in $CSVs){
        $FinalPath = $NewDirectory + $Object
        $FinalPath |`
        # Export to txt file to be copied to a csv and duplicates removed
        Out-File -LiteralPath 'C:\Users\csolomon\Documents\FinalFoldersExports.txt' -Append -NoClobber
    }
    
}  

        
#---------------------------- Chafe Solomon