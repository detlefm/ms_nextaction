Param(
    [Parameter(Mandatory=$true)][string[]] $ServerUrl, $Minutes = 30, [switch] $UseExitCode = $false
)

<#
        .SYNOPSIS
        Gets the busy status of DVBViewer Meadia Server

        .DESCRIPTION
        Gets the busy status of DVBViewer Meadia Server within a limited time
        Default: 30 Minutes

        .PARAMETER ServerUrl
        Specifies the Mediaserver Url including the Port

        .PARAMETER Minutes
        Specifies the minutes, default is 30

        .PARAMETER UseExitCode
        Return values are not piped, they are returned as exit code, default is OFF

        .INPUTS
        None. You cannot pipe objects to ms_action.

        .OUTPUTS
        Number
        Success:
        0  No Events in the given number of minutes
        1  Next timer or next recording within the given number of minutes
        2  Current operations running
        Errors: 
        -1 Invoke-Webrequest failed
        -2 Invalid response of Invoke-Webrequest

        As piped value or as exit code


        .EXAMPLE
        PS> ms_action.ps1 http://localhost:8089 
        1

        .EXAMPLE
        PS> ms_action.ps1 http://localhost:8089 -UseExitCode
        <nothing>
        exit code is 1

        .EXAMPLE
        PS> ms_action.ps1 http://localhost:8089 -Minutes 60
        1

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>


$response = Invoke-WebRequest "http://$ServerUrl/api/status2.html" 
if ($response -and $response.StatusCode -eq 200){
    [xml]$data = $response.Content
    if ($data){
        $seconds = $Minutes * 60
        if ($data.status.timercount -gt 0 -or $data.status.reccount -gt 0 -or $data.status.epgudate -gt 0 ){
            if ($UseExitCode){
                exit 2
            }
            return 2
        }
        if ($data.status.nexttimer -le $seconds -or $data.status.nextrec -le $seconds ){
            if ($UseExitCode){
                exit 1
            }
            return 1
        }
        if ($UseExitCode){
            exit 0
        }
        return 0
    } else {
        if ($UseExitCode){
            exit -2
        }
        -2
    }
} else {
    if ($UseExitCode){
        exit -1
    }
    -1
}