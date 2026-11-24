# ==============================================================================
# Sets NumLock ON at the Windows login screen by setting InitialKeyboardIndicators
# under HKEY_USERS\.DEFAULT, so the state applies before anyone signs in.
# NOTE: needs an elevated session (writes to HKU\.DEFAULT).
# ==============================================================================

#Requires -RunAsAdministrator

$path  = 'HKU:\.DEFAULT\Control Panel\Keyboard'
$name  = 'InitialKeyboardIndicators'
$value = '2'

Set-ItemProperty -Path $path -Name $name -Value $value

Write-Host "NumLock will be ON at the Windows login screen."
