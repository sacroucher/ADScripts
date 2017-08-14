Import-Module ActiveDirectory

 $total = 1000
 for ($userIndex=0; $userIndex -lt $total; $userIndex++) 
 { 
  $userID = "{0:0000}" -f ($userIndex + 1)
  $userName = "test.user$userID"

  Write-Host "Creating user" ($userIndex + 1) "of" $total ":" $userName

  New-ADUser `
   -AccountPassword (ConvertTo-SecureString "AAaaAAaa11!!11" -AsPlainText -Force) `
   -City "City" `
   -Company "Company" `
   -Country "US" `
   -Department "Department" `
   -Description ("TEST ACCOUNT " + $userID + ": This user account does not represent a real user and is meant for test purposes only")`
   -DisplayName "Test User ($userID)" `
   -Division "Division" `
   -EmailAddress "$userName@mentest.org.uk" `
    -EmployeeNumber "$userID" `
   -EmployeeID "ISED$userID" `
   -Enabled $true `
   -Fax "703-555-$userID" `
   -GivenName "Test" `
   -HomePhone "703-556-$userID" `
   -Initials "TU$userID" `
   -MobilePhone "703-557-$userID" `
   -Name "Test User ($userID)" `
   -Office "Office: $userID"`
   -OfficePhone "703-558-$userID" `
   -Organization "Organization" `
   -Path "OU=Users,OU=MenTest,DC=mentest,DC=org,DC=uk" `
   -POBox "PO Box $userID"`
   -PostalCode $userID `
   -SamAccountName $userName `
   -State "VA - Virginia" `
   -StreetAddress "$userID Any Street" `
   -Surname "User ($userID)" `
   -Title "Title" `
   -UserPrincipalName "$userName@mentest.org.uk"
 }