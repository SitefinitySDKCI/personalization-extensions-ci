Import-Module WebAdministration
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null
$currentPath = Split-Path $script:MyInvocation.MyCommand.Path
$variables = Join-Path $currentPath "\Variables.ps1"
. $variables
. $iisModule
. $sqlModule
. $functionsModule

write-output "------- Installing Sitefinity --------"

EnsureDBDeleted $databaseServer $databaseName

RestoreDatabaseWithMove $databaseServer $databaseName $databaseBackupName $databaseBackupLocation

DeleteAllSitesWithSameBinding $defaultWebsitePort

write-output "Setting up Application pool..."

Remove-WebAppPool $appPollName -ErrorAction continue

New-WebAppPool $appPollName -Force

Set-ItemProperty IIS:\AppPools\$appPollName managedRuntimeVersion v4.0 -Force

#Setting application pool identity to NetworkService
Set-ItemProperty IIS:\AppPools\$appPollName processmodel.identityType -Value 2 

write-output "Deploy SitefinityWebApp to test execution machine $machineName"

if (Test-Path $projectBuildLocation){
	CleanWebsiteDirectory $projectBuildLocation 10 $appPollName
}  

write-output "Sitefinity deploying from $projectBuildLocation..."

Copy-Item -Path $projectBackupLocation $projectBuildLocation -Recurse -ErrorAction stop

write-output "Sitefinity successfully deployed."

function InstallSitefinity()
{
	$siteId = GetNextWebsiteId
	write-output "Registering $siteName website with id $siteId in IIS."
	New-WebSite -Id $siteId -Name $siteName -Port $websitePort -HostHeader localhost -PhysicalPath $projectBuildLocation -ApplicationPool $appPollName -Force
	Start-WebSite -Name $siteName

	write-output "Setting up Sitefinity..."

	$installed = $false

	while(!$installed){
		try{    
			$response = GetRequest $websiteUrl
			if($response.StatusCode -eq "OK"){
				$installed = $true;
				$response
			}
		}catch [Exception]{
			Restart-WebAppPool $appPollName -ErrorAction Continue
			write-output "$_.Exception.Message"
			$installed = $false
		}
	}

	write-output "----- Sitefinity successfully installed ------"
}

