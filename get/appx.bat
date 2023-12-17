<# ::
@echo off
title Console Log
mode con cols=100 lines=12
:Begin UAC check and Auto-Elevate Permissions
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo:
echo   Requesting Administrative Privileges...
echo   Press YES in UAC Prompt to Continue
echo:

    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"


start move.exe
cls
@echo.
@echo   лл                                    лл 
@echo   ллББллллл лл ллллллББ ллллллл   ллллББлл ББллллл
@echo   лл     лл          лл    ББлл   лл    лл лл
@echo   лл     лл лл лл    лл ББлл      лл    лл лл
@echo   лл     лл лл лл    лл ллллллл   лллллллл ББллллл
echo ----------------------------------------------------------------------------------------------------

powershell -c "iex ((Get-Content '%~f0') -join [Environment]::Newline); iex 'main %*'"
goto :eof

.SYNOPSIS
This script demonstrate how to embed PowerShell in a BAT file and allow
command-line arguments.

.DESCRIPTION
The top of the script begins with <#:: which is a batch redirection direcctive
meaning that <#: will be parsed as :<# which looks like a label in a batch script
but <# is also a valid powershell comment opener.

The next line turns off echo for batch scripts but remember we're now in a PowerShell
comment block so this is meaningless when the script is loaded by PowerShell.

And the last important line is the third line which invokes powershell.exe, loading
the current script. Note also that it invokes the 'main' function in the content
so we must implement a 'main' function below. Finally, we pass %* into the main
function which is the command-line argument collection for the batch script.


#>

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.

$ErrorActionPreference = 'SilentlyContinue'

$Button = [System.Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [System.Windows.MessageBoxImage]::Error
$Ask = 'Do you want to run this as an Administrator?

        Select "Yes" to Run as an Administrator

        Select "No" to not run this as an Administrator
        
        Select "Cancel" to stop the script.'

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    $Prompt = [System.Windows.MessageBox]::Show($Ask, "Run as an Administrator or not?", $Button, $ErrorIco) 
    Switch ($Prompt) {
        #This will debloat Windows 10
        Yes {
            Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
            Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
            Exit
        }
        No {
            Break
        }
    }
}
#-----------------------------------------------------------------------------------------
$code = @'
using System;
using System.Runtime.InteropServices;

namespace CloseButtonToggle {

 internal static class WinAPI {
   [DllImport("kernel32.dll")]
   internal static extern IntPtr GetConsoleWindow();

   [DllImport("user32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   internal static extern bool DeleteMenu(IntPtr hMenu,
                          uint uPosition, uint uFlags);

   [DllImport("user32.dll")]
   [return: MarshalAs(UnmanagedType.Bool)]
   internal static extern bool DrawMenuBar(IntPtr hWnd);

   [DllImport("user32.dll")]
   internal static extern IntPtr GetSystemMenu(IntPtr hWnd,
              [MarshalAs(UnmanagedType.Bool)]bool bRevert);

   const uint SC_CLOSE     = 0xf060;
   const uint MF_BYCOMMAND = 0;

   internal static void ChangeCurrentState(bool state) {
     IntPtr hMenu = GetSystemMenu(GetConsoleWindow(), state);
     DeleteMenu(hMenu, SC_CLOSE, MF_BYCOMMAND);
     DrawMenuBar(GetConsoleWindow());
   }
 }

 public static class Status {
   public static void Disable() {
     WinAPI.ChangeCurrentState(false); //its 'true' if need to enable
   }
 }
}
'@

Add-Type $code
[CloseButtonToggle.Status]::Disable()

#-----------------------------------------------------------------------------------------

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form                         = New-Object System.Windows.Forms.Form
$form.Text                    = "Install Apps INDOJAVA"
$form.Size                    = New-Object System.Drawing.Size(350, 500)
$form.MaximizeBox             = $false
$Form.MinimizeBox             = $false
$form.AutoSize                = $false
$form.StartPosition           = "Left"
$form.MinimumSize             = New-Object System.Drawing.Size(350, 500) # Ukuran minimal
$form.MaximumSize             = New-Object System.Drawing.Size(350, 500) # Ukuran maksimal
$Form.BackColor               = [System.Drawing.ColorTranslator]::FromHtml("#252525")


# Membuat label
$label                        = New-Object System.Windows.Forms.Label
$label.Location               = New-Object System.Drawing.Point(10,10)
$label.Size                   = New-Object System.Drawing.Size(200,20)
$label.Text                   = "APLIKASI STANDARD:"
$label.Font                   = New-Object System.Drawing.Font('Consolas',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Reguler))
$label.ForeColor              = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")
$form.Controls.Add($label)

# Define applications and their Winget IDs
$applications = @{
    "Google Chrome" = "Google.Chrome"
    "Mozilla Firefox" = "Mozilla.Firefox"
    "VLC Player" = "VideoLAN.VLC"
    "Aimp" = "AIMP.AIMP"
    "Canva" = "Canva.Canva"
    "WhatsApp" = "WhatsAppInc.WhatsApp"
    "Adobe Reader" = "Adobe.AcrobatReaderDC"
    "Mendeley Desktop" = "Mendeley.MendeleyDesktop"
    "PowerToys" = "Microsoft.PowerToys"
    "Visual C++ 2015-2022 Redist (x64)" = "Microsoft.VCRedist.2015+.x64"
    "Visual C++ 2015-2022 Redist (x86)" = "Microsoft.VCRedist.2015+.x86"
    "GOMPlayer" = "GOMLab.GOMPlayer"
    "Blender 3D" = "BlenderFoundation.Blender"
    "Telegram" = "Telegram.TelegramDesktop"
    "Microsoft Teams" = "Microsoft.Teams"
    "WinRar" = "RARLab.WinRAR"
    "7-zip" = "mcmilk.7zip-zstd"
}


# Create a checkbox for each application
$yOffset = 30
$checkboxes = @()
foreach ($appName in $applications.Keys) {
    $checkbox                   = New-Object System.Windows.Forms.CheckBox
    $checkbox.Location          = New-Object System.Drawing.Point(10, $yOffset)
    $checkbox.Size              = New-Object System.Drawing.Size(250, 20)
    $checkbox.Text              = $appName
    $checkbox.Tag               = $applications[$appName] # Assign Winget ID to Tag property
    $checkbox.ForeColor         = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

    $label                   = New-Object System.Windows.Forms.Label
    $label.Location          = New-Object System.Drawing.Point(270, $yOffset)
    $label.Size              = New-Object System.Drawing.Size(200, 20)
    $label.Text              = ""
    $label.ForeColor         = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

    $checkboxes += $checkbox
    $yOffset += 20
    $form.Controls.Add($checkbox)
    $form.Controls.Add($label)
}

# Create an install button

$button                   = New-Object system.Windows.Forms.Button
$button.FlatStyle         = 'Flat'
$button.text              = "INSTALL"
$button.width             = 130
$button.height            = 30
$button.location          = New-Object System.Drawing.Point(110,400)
$button.Font              = New-Object System.Drawing.Font('Consolas',9)
$button.ForeColor         = [System.Drawing.ColorTranslator]::FromHtml("#eeeeee")

$button.Add_Click({
    # Memeriksa apakah winget terinstal
    $wingetInstalled = $null
    try {
        $wingetVersion = winget --version
        if ($wingetVersion) {
            $wingetInstalled = $true
        }
    } catch {
        $wingetInstalled = $false
    }

    if (-not $wingetInstalled) {
        Write-Host "Winget belum terinstal. Silakan instal Winget terlebih dahulu sebelum melanjutkan."
        return
    }

    # Winget sudah terinstal, lanjutkan dengan instalasi aplikasi
    $installedApps = @()
    foreach ($checkbox in $checkboxes) {
        if ($checkbox.Checked) {
            $appId = $checkbox.Tag

            try {
                Write-Host "Installing $appId..."
                Start-Process "winget" -ArgumentList "install -e --accept-source-agreements --accept-package-agreements --id $appId" -NoNewWindow -Wait
                Write-Host "Installed $appId successfully."-ForegroundColor Green
                Write-Host "----------------------------------------------------------------------------------------------------"
                $installedApps += $checkbox.Text
            } catch {
                Write-Host -ForegroundColor Red "Error installing $appId $_"
            }
        }
    }

    if ($installedApps.Count -gt 0) {
        $appsList = $installedApps -join ", "
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Aplikasi berhasil diinstal: $appsList", 15, "Instalasi Selesai", 0x40)
    } else {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Tidak ada aplikasi yang diinstal.", 15, "Instalasi Selesai", 0x40)
    }
})

$form.Controls.Add($button)

[void]$form.ShowDialog()

# Mendapatkan informasi proses dengan nama tertentu
$processName = "AutoIt3"
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process) {
    # Mengakhiri proses berdasarkan nama
    Stop-Process -Name $processName
} else {
    Write-Host "Tidak ada proses dengan nama $processName yang sedang berjalan."
}