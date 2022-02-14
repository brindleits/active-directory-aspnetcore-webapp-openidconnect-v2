[CmdletBinding()]
param(    
    [Parameter(Mandatory=$False, HelpMessage='Tenant ID (This is a GUID which represents the "Directory ID" of the AzureAD tenant into which you want to create the apps')]
    [string] $tenantId,
    [Parameter(Mandatory=$False, HelpMessage='Azure environment to use while running the script. Default = Global')]
    [string] $azureEnvironmentName
)

Function Cleanup
{
    if (!$azureEnvironmentName)
    {
        $azureEnvironmentName = "Global"
    }

    <#
    .Description
    This function removes the Azure AD applications for the sample. These applications were created by the Configure.ps1 script
    #>

    # $tenantId is the Active Directory Tenant. This is a GUID which represents the "Directory ID" of the AzureAD tenant 
    # into which you want to create the apps. Look it up in the Azure portal in the "Properties" of the Azure AD. 

    # Connect to the Microsoft Graph API
    Write-Host "Connecting Microsoft Graph"
    if ($tenantId -eq "") {
        Connect-MgGraph -Scopes "Application.ReadWrite.All" -Environment $azureEnvironmentName
        $tenantId = (Get-MgContext).TenantId
    }
    else {
        Connect-MgGraph -TenantId $tenantId -Scopes "Application.ReadWrite.All" -Environment $azureEnvironmentName
    }
    
    # Removes the applications
    Write-Host "Cleaning-up applications from tenant '$tenantId'"

    Write-Host "Removing 'service' (WebApi-MultiTenant-v2) if needed"
    try
    {
        Get-MgApplication -Filter "DisplayName eq 'WebApi-MultiTenant-v2'"  | ForEach-Object {Remove-MgApplication -ApplicationId $_.Id }
    }
    catch
    {
	    Write-Host "Unable to remove the application 'WebApi-MultiTenant-v2' . Try deleting manually." -ForegroundColor White -BackgroundColor Red
    }

    Write-Host "Making sure there are no more (WebApi-MultiTenant-v2) applications found, will remove if needed..."
    $apps = Get-MgApplication -Filter "DisplayName eq 'WebApi-MultiTenant-v2'"
    
    if ($apps)
    {
        Remove-MgApplication -ApplicationId $apps.Id
    }

    foreach ($app in $apps) 
    {
        Remove-MgApplication -ApplicationId $app.Id
        Write-Host "Removed WebApi-MultiTenant-v2.."
    }

    # also remove service principals of this app
    try
    {
        Get-MgServicePrincipal -filter "DisplayName eq 'WebApi-MultiTenant-v2'" | ForEach-Object {Remove-MgServicePrincipal -ApplicationId $_.Id -Confirm:$false}
    }
    catch
    {
	    Write-Host "Unable to remove ServicePrincipal 'WebApi-MultiTenant-v2' . Try deleting manually from Enterprise applications." -ForegroundColor White -BackgroundColor Red
    }
    Write-Host "Removing 'client' (WebApp-MultiTenant-v2) if needed"
    try
    {
        Get-MgApplication -Filter "DisplayName eq 'WebApp-MultiTenant-v2'"  | ForEach-Object {Remove-MgApplication -ApplicationId $_.Id }
    }
    catch
    {
	    Write-Host "Unable to remove the application 'WebApp-MultiTenant-v2' . Try deleting manually." -ForegroundColor White -BackgroundColor Red
    }

    Write-Host "Making sure there are no more (WebApp-MultiTenant-v2) applications found, will remove if needed..."
    $apps = Get-MgApplication -Filter "DisplayName eq 'WebApp-MultiTenant-v2'"
    
    if ($apps)
    {
        Remove-MgApplication -ApplicationId $apps.Id
    }

    foreach ($app in $apps) 
    {
        Remove-MgApplication -ApplicationId $app.Id
        Write-Host "Removed WebApp-MultiTenant-v2.."
    }

    # also remove service principals of this app
    try
    {
        Get-MgServicePrincipal -filter "DisplayName eq 'WebApp-MultiTenant-v2'" | ForEach-Object {Remove-MgServicePrincipal -ApplicationId $_.Id -Confirm:$false}
    }
    catch
    {
	    Write-Host "Unable to remove ServicePrincipal 'WebApp-MultiTenant-v2' . Try deleting manually from Enterprise applications." -ForegroundColor White -BackgroundColor Red
    }
}

if ($null -eq (Get-Module -ListAvailable -Name "Microsoft.Graph.Applications")) { 
    Install-Module "Microsoft.Graph.Applications" -Scope CurrentUser                                            
} 
Import-Module Microsoft.Graph.Applications
$ErrorActionPreference = "Stop"


Cleanup -tenantId $tenantId -environment $azureEnvironmentName

Write-Host "Disconnecting from tenant"
Disconnect-MgGraph

