﻿#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

Function Get-OSCLastLogonTime
{
<#
 	.SYNOPSIS
        Get-OSCLastLogonTime is an advanced function which can be used to get active directory user's last logon time.
    .DESCRIPTION
        Get-OSCLastLogonTime is an advanced function which can be used to get active directory user's last logon time.
    .PARAMETER  SamAccountName
        Specifies the SamAccountName
    .PARAMETER  CsvFilePath
		Specifies the path you want to import csv files.
    .EXAMPLE
        C:\PS> Get-OSCLastLogonTime -SamAccountName "Administrator","lindawang"

        SamAccountName                   LastLogonTimeStamp                                                   
        --------------                   ------------------                                                   
        administrator                    9/25/2013 2:23:43 AM                                                 
        lindawang                        12/31/1600 4:00:00 PM 

		This command will list all active directory users' last logon time info.
    .EXAMPLE
        C:\PS> Get-OSCLastLogonTime -CsvFilePath C:\Script\SamAccountName.txt
        
        SamAccountName                   LastLogonTimeStamp                                                   
        --------------                   ------------------                                                   
        administrator                    9/25/2013 2:23:43 AM                                                 
        lindawang                        12/31/1600 4:00:00 PM 

		This command will list user's last logon time info from your specified csv file.
#>

    [CmdletBinding(DefaultParameterSetName='UserName')]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ParameterSetName='UserName')]
        [String[]]$SamAccountName,
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='CsvFilePath')]
        [String]$CsvFilePath
    )
    
    #The first ParameterSetName
    If($SamAccountName)
    {
        Foreach($UserName in $SamAccountName)
        {
            #Invoke the custome method
            QueryActiveDirectory -UserName $UserName
        }
    }

    #The second ParameterSetName
    If($CsvFilePath)
    {
        If(Test-Path -Path $CsvFilePath)
        {
            If((Get-ChildItem -Path $CsvFilePath).Extension -eq ".csv")
            {
                $SamAccountName = (Import-Csv -Path $CsvFilePath).SamAccountName
                
                ForEach($UserName in $SamAccountName)
                {
                    QueryActiveDirectory -UserName $UserName
                }
            }
            Else
            {
                Write-Warning "The file is not a csv file, please check it."
            }
        }
        Else
        {
            Write-Warning "The path '$CsvFilePath' cannot find. Please make sure that it exists."
        }
    }
}

Function QueryActiveDirectory([String]$UserName)
{
    $Filter = "(&(objectCategory=User)(SamAccountName=$UserName))"
            
    $Domain = New-Object System.DirectoryServices.DirectoryEntry 
    $Searcher = New-Object System.DirectoryServices.DirectorySearcher
    $Searcher.SearchRoot = "LDAP://$($Domain.DistinguishedName)"
    $Searcher.PageSize = 1000
    $Searcher.SearchScope = "Subtree"
    $Searcher.Filter = $Filter
    $Searcher.PropertiesToLoad.Add("DistinguishedName") | Out-Null
    $Searcher.PropertiesToLoad.Add("LastLogonTimeStamp") | Out-Null

    $Results = $Searcher.FindAll()
    
    #Check if the account exists.
    If($Results.Count -eq 0)
    {
        Write-Warning "The SamAccountName '$UserName' cannot find. Please make sure that it exists."
    }
    Else
    {
        Foreach($Result in $Results)
        {
            $DistinguishedName = $Result.Properties.Item("DistinguishedName")
            $LastLogonTimeStamp = $Result.Properties.Item("LastLogonTimeStamp")
            
            If ($LastLogonTimeStamp.Count -eq 0)
            {
                $Time = [DateTime]0
            }
            Else
            {
                $Time = [DateTime]$LastLogonTimeStamp.Item(0)
            }
            If ($LastLogonTimeStamp -eq 0)
            {
                $LastLogon = $Time.AddYears(1600)
            }
            Else
            {
                $LastLogon = $Time.AddYears(1600).ToLocalTime()
            }

            #Output in comma delimited format.
            $Hash = @{
                        SamAccountName = $UserName
                        LastLogonTimeStamp = $(If($LastLogon -match "12/31/1600")
                                               {
                                                    "Never Logon"
                                               }
                                               Else
                                               {
                                                    $LastLogon
                                               })
                     }
            $Objs = New-Object -TypeName PSObject -Property $Hash

            $Objs                        
        }
    }
}
