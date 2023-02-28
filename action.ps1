# HelloID-Task-SA-Target-ActiveDirectory-AccountDelete
######################################################
# Form mapping
$formObject = @{
    UserPrincipalName     = $form.UserPrincipalName
}

try {
    Write-Information "Executing ActiveDirectory action: [DeleteAccount] for: $($formObject.UserPrincipalName)]"

    Import-Module ActiveDirectory -ErrorAction Stop
    $user = Get-ADUser -Filter "userPrincipalName -eq '$($formObject.UserPrincipalName)'"
    if ($user) {

        $null = Remove-ADObject -Identity $User.DistinguishedName -Recursive -Confirm:$false
        $auditLog = @{
            Action            = 'DeleteAccount'
            System            = 'ActiveDirectory'
            TargetIdentifier  =  "$($user.SID.value)"
            TargetDisplayName = "$($formObject.UserPrincipalName)"
            Message           = "ActiveDirectory action: [DeleteAccount] for: [$($formObject.UserPrincipalName)] executed successfully"
            IsError           = $false
        }
        Write-Information -Tags 'Audit' -MessageData $auditLog
        Write-Information "ActiveDirectory action: [DeleteAccount] for: [$($formObject.UserPrincipalName)] executed successfully"
    } elseif (-not($user)) {
        $auditLog = @{
            Action            = 'DeleteAccount'
            System            = 'ActiveDirectory'
            TargetIdentifier  = ""
            TargetDisplayName = "$($formObject.UserPrincipalName)"
            Message           = "ActiveDirectory action: [DeleteAccount] for: [$($formObject.UserPrincipalName)] cannot execute. The account cannot be found in the AD. Possibly already deleted"
            IsError           = $true
        }
        Write-Information -Tags 'Audit' -MessageData $auditLog
        Write-Error "ActiveDirectory action: [DeleteAccount] for: [$($formObject.UserPrincipalName)] cannot execute. The account cannot be found in the AD. Possibly already deleted"
    }
} catch {
    $ex = $_
    $auditLog = @{
        Action            = 'DeleteAccount'
        System            = 'ActiveDirectory'
        TargetIdentifier  = '' # optional (free format text)
        TargetDisplayName = "$($formObject.UserPrincipalName)"
        Message           = "Could not execute ActiveDirectory action: [DeleteAccount] for: [$($formObject.UserPrincipalName)], error: $($ex.Exception.Message)"
        IsError           = $true
    }
    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute ActiveDirectory action: [DeleteAccount] for: [$($formObject.UserPrincipalName)], error: $($ex.Exception.Message)"
}