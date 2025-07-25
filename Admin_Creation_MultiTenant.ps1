# ================================
# Powershell Creation Compte Admin 
#  Connexion   MS365   MultiTenant
#                  ..::: Fab :::..
# ================================

$defaultUsername = 'agent365@mondomaine.fr' 											 # A PERSONNALISER (indiquer votre compte Agent365)
$DisplayName = "Admin 365 XXXXX - XXXXXXXXXXXX"										 # A PERSONNALISER (indiquer le Nom d'affichage pour le nouveau compte admin)
$adminClient = 'admin_XXXXXX'  															 # A PERSONNALISER (indiquer le Login pour le nouveau compte admin)
$securePassword = ConvertTo-SecureString "MotDePasseTemporaire123!" -AsPlainText -Force  # A PERSONNALISER (indiquer le MDP pour le nouveau compte admin)
$GivenName = 'Xxxxxx'																 	 # A PERSONNALISER (indiquer le Prenom pour le nouveau compte admin)
$Surname = 'XXXXXX'																		 # A PERSONNALISER (indiquer le Nom pour le nouveau compte admin)

#$PasswordTempAdmin = "MotDePasseAdminTemporaire123!" # A PERSONNALISER (mdp a associer au nouveau compte admin a creer)

# Encodage utilisé.
#chcp 65001
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(65001)

# Vide le contenu de la fenêtre Powershell
Clear-Host

# Fonction des logs du script
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [$Level] $Message" | Out-File -Append -FilePath ".\admin_script.log"
}

# Vérification et installation des modules nécessaires
$modules = @(
    @{ Name = 'PartnerCenter'; MinimumVersion = '4.0.0' },
    @{ Name = 'AzureAD'; MinimumVersion = '2.0.2.140' }
)
$allModulesPresent = $true
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod.Name)) {
        $allModulesPresent = $false
    }
}
if ($allModulesPresent) {
    Write-Host "Tous les modules necessaires sont deja installes. L'execution va continuer..." -ForegroundColor Green
    Start-Sleep -Seconds 2
} else {
    foreach ($mod in $modules) {
        if (-not (Get-Module -ListAvailable -Name $mod.Name)) {
            Write-Host "Module $($mod.Name) non trouve. Installation en cours..." -ForegroundColor Yellow
            try {
                if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                    Write-Host "Elevation des privileges pour installer le module $($mod.Name)..." -ForegroundColor Cyan
                    $command = "Install-Module -Name $($mod.Name) -MinimumVersion $($mod.MinimumVersion) -Force -Scope AllUsers -AllowClobber"
                    Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -Command $command"
                    Write-Host "Veuillez relancer le script apres l'installation du module." -ForegroundColor Red
                    exit
                } else {
                    Install-Module -Name $($mod.Name) -MinimumVersion $($mod.MinimumVersion) -Force -Scope AllUsers -AllowClobber
                    Write-Host "Module $($mod.Name) installe." -ForegroundColor Green
                }
            } catch {
                Write-Host "Erreur lors de l'installation du module $($mod.Name) : $($_.Exception.Message)" -ForegroundColor Red
                exit
            }
        }
    }
}

function Start-AdminMenu {
    param(
        [string]$Username,
        [string]$DomainNameId,
        [string]$ClientName,
		[string]$adminClient,
		[string]$DisplayName,
		[string]$securePassword,
		[string]$GivenName,
		[string]$Surname
    )
    $adminUPN = "'$adminClient'+'@'$DomainNameId'"
    $menuScript = @"
Import-Module AzureAD
$Host.UI.RawUI.WindowTitle = "AzureAD-$ClientName"

# Vide le contenu de la fenêtre Powershell
Clear-Host

function Write-Menu {
    Write-Host "" -ForegroundColor White
    Write-Host "===== MENU ADMIN $ClientName ($DomainNameId) =====" -ForegroundColor Yellow
    Write-Host "1. Tester la presence du compte admin ($adminUPN)" -ForegroundColor Cyan
    Write-Host "2. Ajouter le compte admin ($adminUPN)" -ForegroundColor Green
    Write-Host "3. Supprimer le compte admin ($adminUPN)" -ForegroundColor Red
    Write-Host "4. Quitter" -ForegroundColor Magenta
    Write-Host "===============================================" -ForegroundColor Yellow
}

try {
    Connect-AzureAD -TenantDomain '$DomainNameId'
    Write-Host "Connecte a AzureAD ($DomainNameId)" -ForegroundColor Green
} catch {
    Write-Host "Erreur de connexion AzureAD : $($_.Exception.Message)" -ForegroundColor Red
}

while (`$true) {
    Write-Menu
    `$choice = Read-Host -Prompt "Choix (1/2/3/4)"
    switch (`$choice) {
        '1' {
            Write-Host "Test de la presence du compte $adminUPN..." -ForegroundColor Cyan
            try {
                `$user = Get-AzureADUser -SearchString "$adminUPN"
                if (`$user) {
                    Write-Host "Le compte $adminUPN existe." -ForegroundColor Green
                } else {
                    Write-Host "Le compte $adminUPN n'existe pas." -ForegroundColor Red
                }
            } catch {
                Write-Host "Le compte $adminUPN n'existe pas." -ForegroundColor Red
            }
        }
        '2' {
            Write-Host "Creation du compte $adminUPN..." -ForegroundColor Green
			
			$user = New-PartnerCustomerUser -CustomerId $TenantName -UserPrincipalName $adminUPN `
				-DisplayName `$DisplayName `
				-FirstName `$FirstName `
				-LastName `$LastName `
				-UsageLocation "FR" `
				-Password `$securePassword
			
         ##   try {
         ##       `$user = Get-AzureADUser -SearchString "$adminUPN"
         ##       if (-not `$user) {
         ##           `$plainPassword = $PasswordTempAdmin
         ##           `$passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
         ##           `$passwordProfile.Password = `$plainPassword
         ##           `$passwordProfile.ForceChangePasswordNextLogin = `$false
		 ##
         ##           `$newUser = New-AzureADUser -DisplayName `$DisplayName \
         ##               -PasswordProfile `$passwordProfile \
         ##               -UserPrincipalName `$adminUPN \
         ##               -AccountEnabled `$true \
         ##               -MailNickName `$adminClient \
         ##               -GivenName `Fabien \
         ##               -Surname `FABRE
		 
		 
                    Write-Host "Compte $adminUPN cree avec succes." -ForegroundColor Green
                    `$user = `$newUser
                } else {
                    Write-Host "Le compte $adminUPN existe deja." -ForegroundColor Yellow
                }

                `$role = Get-AzureADDirectoryRole | Where-Object { `$_.DisplayName -eq "Global Administrator" }
                if (-not `$role) {
                    Enable-AzureADDirectoryRole -RoleTemplateId "62e90394-69f5-4237-9190-012177145e10"
                    `$role = Get-AzureADDirectoryRole | Where-Object { `$_.DisplayName -eq "Global Administrator" }
                }

                Add-AzureADDirectoryRoleMember -ObjectId `$role.ObjectId -RefObjectId `$user.ObjectId
                Write-Host "Role Global Administrator assigne a $adminUPN." -ForegroundColor Green
            } catch {
                Write-Host "Erreur lors de la creation ou de l'assignation du role : $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Exception detail : $($_ | Out-String)" -ForegroundColor Red
            }
        }
        '3' {
            Write-Host "Suppression du compte $adminUPN..." -ForegroundColor Red
            try {
                Remove-AzureADUser -ObjectId "$adminUPN" -ErrorAction Stop
                Write-Host "Compte $adminUPN supprime avec succes." -ForegroundColor Green
            } catch {
                Write-Host "Erreur lors de la suppression : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        '4' {
            Write-Host "Fermeture du menu pour $ClientName. A bientot !" -ForegroundColor Magenta
            break
        }
        default {
            Write-Host "Entree invalide. Merci de choisir 1, 2, 3 ou 4." -ForegroundColor Red
        }
    }
}
"@
    $tempFile = [System.IO.Path]::GetTempFileName() -replace '.tmp$', '.ps1'
    Set-Content -Path $tempFile -Value $menuScript -Encoding UTF8
    Start-Process powershell.exe -ArgumentList @("-NoExit", "-File", $tempFile)
}

# ------------------------------------------------------------
# Configuration : UPN administrateur delegue
# ------------------------------------------------------------
$UsernameInput = Read-Host -Prompt "Entrez l'UPN de l'administrateur delegue ou appuyez sur Entree pour utiliser le compte par defaut ($defaultUsername)"
$Username = if ([string]::IsNullOrWhiteSpace($UsernameInput)) { $defaultUsername } else { $UsernameInput }

# ------------------------------------------------------------
# Connexion au Partner Center
# ------------------------------------------------------------
Write-Host "Connexion au Centre Partenaire Microsoft 365..." -ForegroundColor Cyan
Write-Host ""
try {
    Connect-PartnerCenter
    Write-Host ""
    Write-Host "Connecte au Centre Partenaire !" -ForegroundColor Green
    Write-Host ""
    Write-Log "Connexion reussie au Partner Center avec $Username"
} catch {
    Write-Host "Echec de la connexion : $($_.Exception.Message)" -ForegroundColor Red
    Write-Log "Erreur de connexion au Partner Center : $($_.Exception.Message)" "ERROR"
    exit
}

function Get-ClientList {
    Write-Host "Recuperation de la liste des clients..." -ForegroundColor Cyan
    Write-Host ""
    $clients = Get-PartnerCustomer | Sort-Object Name

    $search = Read-Host -Prompt "Filtrer les clients par nom, domaine ou ID (laisser vide pour tout afficher)"
    if (-not [string]::IsNullOrWhiteSpace($search)) {
        $clients = $clients | Where-Object {
            $_.Name -like "*$search*" -or
            $_.Domain -like "*$search*" -or
            $_.CustomerId -like "*$search*"
        }
    }

    $clientObj = @()
    $i = 0
    foreach ($client in $clients) {
        $clientObj += [PSCustomObject]@{
            Number      = $i
            ClientName  = $client.Name
            TenantId    = $client.CustomerId
            DomainName  = $client.Domain
        }
        $i++
    }

    return ,$clientObj
}

$clientObj = Get-ClientList
Write-Host "Nombre de clients trouves : $($clientObj.Count)" -ForegroundColor Magenta

# ------------------------------------------------------------
# Boucle principale
# ------------------------------------------------------------
while ($true) {
    if ($clientObj.Count -eq 0) {
        Write-Host "Aucun client trouve avec ce filtre. Essayez un autre mot-cle ou tapez 'A'." -ForegroundColor Red
        $clientObj = Get-ClientList
        continue
    }

    Write-Host "Liste des tenants disponibles :" -ForegroundColor Yellow
    Write-Host ""
    foreach ($client in $clientObj) {
        $num    = $client.Number.ToString().PadLeft(3)
        $name   = $client.ClientName
        $domain = $client.DomainName
        $Tenant = $client.TenantId
        Write-Host "$num : $name" -ForegroundColor White
        Write-Host "      -> $domain" -ForegroundColor DarkGray
        Write-Host "      -> $Tenant" -ForegroundColor DarkGray
    }

    $clientChoice = Read-Host -Prompt "Selectionner le numero du tenant, taper 'A' pour actualiser, ou 'Q' pour quitter"

    switch ($clientChoice.ToLower()) {
        'q' {
            Write-Host "Merci d'avoir utilise ce script. A bientot !" -ForegroundColor Cyan
            Write-Log "Script termine par l'utilisateur"
            exit
        }
        'a' {
            $clientObj = Get-ClientList
            Write-Host "Nombre de clients trouves : $($clientObj.Count)" -ForegroundColor Magenta
            continue
        }
        default {
            if ($clientChoice -match '^\d+$') {
                $index = [int]$clientChoice
                if ($index -ge 0 -and $index -lt $clientObj.Count) {
                    $selectedClient = $clientObj[$index]
                    $DomainNameId = $selectedClient.DomainName
                    $ClientName = $selectedClient.ClientName
                    $TenantName = $selectedClient.TenantId
                    Write-Host "Ouverture d'une fenetre de gestion pour $ClientName ($DomainNameId)..." -ForegroundColor Cyan
                    Write-Log "Ouverture d'une fenetre de gestion pour $ClientName ($DomainNameId)"
                    Start-AdminMenu -Username $Username -DomainNameId $DomainNameId -ClientName $ClientName
                } else {
                    Write-Host "Numero hors plage, merci de reessayer." -ForegroundColor Red
                }
            } else {
                Write-Host "Entree invalide. Veuillez saisir un numero valide, 'A' pour actualiser ou 'Q' pour quitter" -ForegroundColor Red
            }
        }
    }
}
