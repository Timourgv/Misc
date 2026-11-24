function Get-LocalAdmins {
    <#
    .SYNOPSIS
    Gets the members of the local Administrators group on one or more remote
    computers. CIM-based, so it works in Windows PowerShell 5.1 and PowerShell 7
    (the old version used Get-WmiObject, which no longer exists in PS7).

    .PARAMETER Computers
    Specifies the computer names of devices to query.

    .INPUTS
    System.String. Get-LocalAdmins can accept a string value to
    determine the Computers parameter.

    .EXAMPLE
    Get-LocalAdmins -Computers CL1,CL2

    .EXAMPLE
    Get-LocalAdmins -Computers (Get-Content -Path ".\computers.txt")

    .EXAMPLE
    Get-LocalAdmins -Computers DC,SVR8 | Format-Table -AutoSize -Wrap

    .EXAMPLE
    Get-LocalAdmins -Computers DC,SVR8 | Export-Csv -Path ".\LocalAdmin.csv" -NoTypeInformation

    .NOTES
    Modernized cleanup of the original Technet Gallery script
    (https://gallery.technet.microsoft.com/223cd1cd-2804-408b-9677-5d62c2964883):
    Get-WmiObject -> Get-CimInstance, initialized variables, sane output objects.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Computers
    )

    foreach ($computer in $Computers) {
        if (-not (Test-Connection -ComputerName $computer -Quiet -Count 1)) {
            Write-Verbose "$computer is unreachable"
            continue
        }

        $admins = Get-CIMInstance -ClassName Win32_GroupUser -ComputerName $computer |
            Where-Object { $_.GroupComponent -like '*"Administrators"' }

        $members = foreach ($admin in $admins) {
            # PartComponent looks like: \\PC\root\cimv2:Win32_UserAccount.Domain="CONTOSO",Name="jdoe"
            if ($admin.PartComponent -match 'Domain\="?(.+?)"?,\s*Name\="?(.+?)"?\s*$') {
                '{0}\{1}' -f $Matches[1], $Matches[2]
            }
            elseif ($admin.PartComponent) {
                $admin.PartComponent
            }
        }

        [PSCustomObject]@{
            ComputerName = $computer
            LocalAdmins  = @($members | Sort-Object -Unique) -join "`n"
        }
    }
}
