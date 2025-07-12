# True automatic clipboard monitor using Windows events
param(
    [string]$SaveDirectory = "~/.screenshots",
    [string]$WslDistro = "auto"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Convert the tilde path to WSL format
if ($SaveDirectory -eq "~/.screenshots") {
    # Try to auto-detect WSL distribution if auto mode is used
    if ($WslDistro -eq "auto") {
        $WslDistros = @(wsl.exe -l -q | Where-Object { 
            $_ -and $_.Trim() -ne "" -and $_ -notlike "*docker*" 
        } | ForEach-Object { 
            $_.Trim() -replace '\s+', '' -replace '\x00', ''
        })
        if ($WslDistros.Count -gt 0) {
            $WslDistro = $WslDistros[0]
            Write-Host "Auto-detected WSL distribution: $WslDistro"
        }
    }
    
    # Get the actual WSL username instead of Windows username
    $WslUsername = wsl.exe -d $WslDistro -e whoami
    $WslUsername = $WslUsername.Trim()
    $SaveDirectory = "\\wsl.localhost\$WslDistro\home\$WslUsername\.screenshots"
}

if (!(Test-Path $SaveDirectory)) {
    New-Item -ItemType Directory -Path $SaveDirectory -Force | Out-Null
}

Write-Host "WINDOWS-TO-WSL2 SCREENSHOT AUTOMATION STARTED"
Write-Host "Auto-saving images to: $SaveDirectory"
Write-Host "Press Ctrl+C to stop"



Write-Host "Monitoring clipboard events and directory changes..."
$previousHash = $null
$lastFileTime = Get-Date

# WSL session check variables
$sessionCheckInterval = 50  # Check every 25 seconds (50 * 500ms)
$loopCount = 0

# Function to copy path to both clipboards
function Set-BothClipboards($path) {
    try {
        [System.Windows.Forms.Clipboard]::SetText($path)
        $wslCommand = "echo '$path' | clip.exe"
        wsl.exe -d $WslDistro -e bash -c $wslCommand
        return $true
    } catch {
        Start-Sleep -Milliseconds 200
        try {
            [System.Windows.Forms.Clipboard]::SetText($path)
            $wslCommand = "echo '$path' | clip.exe" 
            wsl.exe -d $WslDistro -e bash -c $wslCommand
            return $true
        } catch {
            Write-Warning "Could not set clipboard: $_"
            return $false
        }
    }
}

while ($true) {
    try {
        Start-Sleep -Milliseconds 500
        
        # Check if we should continue running
        if (($loopCount % $sessionCheckInterval) -eq 0) {
            # Check if signal file exists (manual stop)
            if (!(Test-Path "$SaveDirectory\.monitor_active")) {
                Write-Host "Stop signal detected, exiting monitor..."
                exit 0
            }
            
            # Check if WSL session is still active
            try {
                $null = wsl.exe -d $WslDistro -e echo "ping" 2>$null
                if ($LASTEXITCODE -ne 0) {
                    Write-Host "WSL session lost, exiting monitor..."
                    exit 0
                }
            } catch {
                Write-Host "WSL session lost, exiting monitor..."
                exit 0
            }
        }
        $loopCount++
        
        if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
            $image = [System.Windows.Forms.Clipboard]::GetImage()
            if ($image) {
                $ms = New-Object System.IO.MemoryStream
                $image.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
                $imageBytes = $ms.ToArray()
                $ms.Dispose()
                $currentHash = [System.BitConverter]::ToString([System.Security.Cryptography.SHA256]::Create().ComputeHash($imageBytes))
                
                if ($currentHash -ne $previousHash) {
                    Write-Host "New image detected in clipboard"
                    
                    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
                    $filename = "screenshot_$timestamp.png"
                    $filepath = Join-Path $SaveDirectory $filename
                    $image.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
                    
                    $latestPath = Join-Path $SaveDirectory "latest.png"
                    if (Test-Path $latestPath) { Remove-Item $latestPath -Force }
                    Copy-Item $filepath $latestPath -Force
                    
                    # Create full path for WSL2 instead of using tilde
                    $wslPath = "/home/$WslUsername/.screenshots/$filename"
                    Start-Sleep -Milliseconds 1000
                    
                    if (Set-BothClipboards $wslPath) {
                        Write-Host "AUTO-SAVED: $filename"
                        Write-Host "Path ready for Ctrl+V: $wslPath"
                    }
                    
                    $previousHash = $currentHash
                }
                $image.Dispose()
            }
        }
        
        # Also check for new files in the directory (for drag-drop screenshots)
        $currentTime = Get-Date
        $newFiles = Get-ChildItem $SaveDirectory -Filter "*.png" | Where-Object { 
            $_.LastWriteTime -gt $lastFileTime -and $_.Name -ne "latest.png" 
        }
        
        if ($newFiles) {
            foreach ($file in $newFiles) {
                # Create full path for WSL2 instead of using tilde
                $wslPath = "/home/$WslUsername/.screenshots/$($file.Name)"
                Copy-Item $file.FullName (Join-Path $SaveDirectory "latest.png") -Force
                
                if (Set-BothClipboards $wslPath) {
                    Write-Host "NEW FILE DETECTED: $($file.Name)"
                    Write-Host "Path ready for Ctrl+V: $wslPath"
                }
            }
            $lastFileTime = $currentTime
        }
        
    } catch {
        Write-Warning "Error in main loop: $_"
        Start-Sleep -Milliseconds 1000
    }
}
