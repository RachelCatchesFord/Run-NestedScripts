<#
    Author: Rachel Catches-Ford
    Version: 1.0.0.0
    Date: 2019-02-26

    Purpose: Runs all .ps1 files found in the specified locations.
            Then activates Windows 10 with Enterprise W10 key and
            Office 2010 with MAK key. Waits for 10 seconds, then 
            restarts the computer.

#>

$SoftwareDir = "$PSScriptRoot\Software"
$ConfigDir = "$PSScriptRoot\Config"
$HardeningDir = "$PSScriptRoot\Hardening"
$LaptopDir = "$PSScriptRoot\LaptopSoftware"
$DriversDir = "$PSScriptRoot\Drivers"
Start-Transcript -Path "C:\Windows\Logs\NewImageSetup.log" -Append
Function Get-Scripts{

    param([string]$Directory)



    $Directory | Get-ChildItem | ForEach-Object {
    if($_.Name -like "*.ps1"){
            Write-Host($_.FullName)
             & $_.FullName | Out-Null -Verbose

        } else {
        $_ | Get-ChildItem | ForEach-Object {
            if($_.Name -like "*.ps1"){
                Write-Host($_.FullName)
                & $_.FullName | Out-Null -Verbose
            }
        }
    }

}

}

Function Detect-Laptop{
    Param( 
        [string]$computer = "localhost"
        )
    
    $isLaptop = $false

    #The chassis is the physical container that houses the components of a computer. Check if the machine's chasis type is 9.Laptop 10.Notebook 14.Sub-Notebook
    if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14}){
        $isLaptop = $true 
    }

    #Shows battery status , if true then the machine is a laptop.
    if(Get-WmiObject -Class win32_battery -ComputerName $computer){
        $isLaptop = $true 
    }
    $isLaptop
}

Write-Host ('Installing Software')
Get-Scripts -Directory "$SoftwareDir" -Verbose

If(Detect-Laptop) { 
    Write-Host ('Installing Laptop Specific Software')
    Get-Scripts -Directory "$LaptopDir" -Verbose 
}

Write-Host ('Installing Hardening Settings')
Get-Scripts -Directory "$HardeningDir" -Verbose

Write-Host ('Setting Configurations & Shtuff')
Get-Scripts -Directory "$ConfigDir" -Verbose

Write-Host ('Activating Windows and Office')
& "C:\ActivationsWithRestore\ActivationsNoReboot.exe" | Out-Null -Verbose

Stop-Transcript

Write-Host ('Restarting Computer')
Restart-Computer -Force

