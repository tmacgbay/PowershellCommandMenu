<#
.SYNOPSIS
   Create a hierarchical menu that allows for choosing Powershell commands

.DESCRIPTION
   Recursive hierarchical menu that allows you either to run a powershell command or create a submenu for each line

.EXAMPLE   
   - Function hash_<menuName> are the written structure of each menu and the commands that go with each line
   - menu_line - is the wording for the menu choice
   - menu_action - is either the powershell command to run when that choice is made or a call to a submenu in the form of 'present_choice "<Menu Title>" <hash_menuname>' 
   - Add as many choices into a HashMenu list as needed using


.NOTES
    Author:         Tad Sherrill
        
    2022-02-22:
        - Created script
        - 

    01-06-2023:
        - Did future things

#>




<################### Menu Presentation and Choice ###############################>


function make-menu {
    param (
        [string]      $local:table_name    = 'unNamed',
        [hashtable]   $local:menu_hash
    )

    Clear-Host
    Write-Host 
    Write-Host "================ $local:table_name ==================="
    Write-Host 
    Write-Host $top_message -fore Green
    Write-Host "" -fore White

     $local:menu_hash.GetEnumerator() | sort-object -Property name  | foreach {
          Write-host $_.name: $_.value.menu_line
          Write-Host
    }

    Write-Host
    if ($local:table_name -eq "Main Menu") {
        Write-Host "============= 'Q'uit ================"
    } else {
        Write-Host "=========== 'Q'uit or 'B'ack ==============="
    }
   
    Write-Host

}


function present_choice   {    
    param (
        $menu_name,
        $hash_name
    )
        $all_choice = @{}
        $this_menu = $(& $hash_name)
        
        $all_choice = foreach ($choice in $this_menu.GetEnumerator()) {
            [string]$choice.name
        }   
        
        do {
            make-menu $menu_name $this_menu
            $decision  = Read-Host "Please make a selection"
            if ([regex]::Match($decision, "[q]").value) {exit}
            if ([regex]::Match($decision, "[b]").value) {break}
            if ($all_choice -contains $decision)  {
                invoke-expression -Command $this_menu.([int]$decision).menu_action
            }
        } until ([regex]::Match($decision, "[qb]").value) 
 
     return ($decision)
}



<################### Menu Builds ###############################>

function hash_main_menu {
    $menu_build = @{
        1 = @{
            menu_line     = "Menu ONE options..."
            menu_action   = 'present_choice "Menu ONE Options" hash_menuOne'
        }
        2 = @{
            menu_line     = "Show execution policy"
            menu_action   = 'get-executionpolicy; pause'
        }
        3 = @{
            menu_line     = "Menu THREE options..."
            menu_action   = 'present_choice "THIRD Choice" hash_3dchoice'
        }
    }
    return($menu_build)
}

function hash_menuOne {
    $menu_build = @{
        1 = @{
            menu_line     = "A choice of thing to do... or another submenu"
            menu_action   = 'present_choice "Menu DOWN A LEVEL Options" hash_name_does_not_matter'
        }
        2 = @{
            menu_line     = "Another  thing"
            menu_action   = 'No Action'
        }
    }
    return($menu_build)
}

function hash_3dchoice {
    $menu_build = @{
        1 = @{
            menu_line      = "Tile of action"
            menu_action    = 'action to be taken'
        }
        2 = @{
            menu_line      = "title of other action"
            menu_action    = 'Other Other Action to be taken'
        }

    }
    return($menu_build)
}


function hash_4dchoice {
    $menu_build = @{
        1 = @{
            menu_line      = "Show Execution Policy"
            menu_action    = 'get-executionpolicy; pause'
        }
        2 = @{
            menu_line      = "test menu item"
            menu_action    = 'ls;pause'
        }

    }
    return($menu_build)
}

<################### Supporting Functions ###############################>

Function DomAdmin-Check {

    $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)
    
    if($WindowsPrincipal.IsInRole("Domain Admins")){
        Return ("$($currentUser.Name) is a Domain Admin")
    }else{
        Write-Host "$($currentUser.Name) not a Domain Admin. Stopping All" -fore Red
        exit
    }

}



<# Main #>
    $top_message  = DomAdmin-Check
    $decision     = present_choice "Main Menu" hash_main_menu

