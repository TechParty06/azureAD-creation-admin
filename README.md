# Script PowerShell – Gestion des comptes admin M365 Multi-Tenants

Ce script PowerShell permet de :
- Lister les tenants d’un partenaire Microsoft 365 (via PartnerCenter)
- Ouvrir un menu interactif pour chaque tenant
- Tester, créer ou supprimer un compte admin (admin_xxxxx@domaine)
- Assigner automatiquement le rôle « Global Administrator » au compte créé

## Fonctionnalités principales

- **Vérification automatique des modules nécessaires** (`AzureAD`, `PartnerCenter`)
- **Connexion sécurisée** au Partner Center pour récupérer la liste des clients
- **Menu interactif** pour chaque tenant :
  - Tester la présence du compte admin
  - Créer le compte admin (avec mot de passe temporaire)
  - Assigner le rôle « Global Administrator »
  - Supprimer le compte admin
- **Logs** des actions dans un fichier local

## Prérequis

- PowerShell 5.1 ou supérieur
- Modules PowerShell : `AzureAD` (≥ 2.0.2.140), `PartnerCenter` (≥ 4.0.0)
- Droits administrateur pour installer les modules si besoin

## Installation

1. Clonez le dépôt ou téléchargez le script dans le dossier de votre choix.
2. Ouvrez une console PowerShell en tant qu’administrateur si besoin.

## Utilisation

1. **Personnalisez les variables** en haut du script :
   - `$defaultUsername` : votre compte agent principal
   - `$PasswordTempAdmin` : mot de passe temporaire pour le compte admin à créer
2. Exécutez le script :
   ```powershell
   .\test.ps1
   ```
3. Suivez les instructions à l’écran pour sélectionner un tenant et gérer le compte admin.

## Exemple de menu interactif

```
===== MENU ADMIN XXX (xxxxx.onmicrosoft.com) =====
1. Tester la presence du compte admin (admin_xxxxxx@xxxxxx.onmicrosoft.com)
2. Ajouter le compte admin (admin_xxxxxx@xxxxxx.onmicrosoft.com)
3. Supprimer le compte admin (admin_xxxxxx@xxxxxx.onmicrosoft.com)
4. Quitter
===============================================
```

## Auteur

- Fab

## Licence

MIT

## Liens utiles

- [Module AzureAD](https://www.powershellgallery.com/packages/AzureAD)
- [Module PartnerCenter](https://www.powershellgallery.com/packages/PartnerCenter)
- [Documentation Microsoft Graph PowerShell](https://learn.microsoft.com/powershell/microsoftgraph/overview) 
