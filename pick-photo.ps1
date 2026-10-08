$ErrorActionPreference = 'Stop'
$owner = $null

function Show-PluginError([string] $Message, $Owner) {
    if ($null -ne $Owner) {
        [System.Windows.Forms.MessageBox]::Show(
            $Owner, $Message, 'Herdr Photo Picker',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    } else {
        [System.Windows.Forms.MessageBox]::Show(
            $Message, 'Herdr Photo Picker',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
}

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # An invisible topmost owner keeps the native dialog in front of Herdr.
    $owner = New-Object System.Windows.Forms.Form
    $owner.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
    $owner.ShowInTaskbar = $false
    $owner.ShowIcon = $false
    $owner.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $owner.Size = New-Object System.Drawing.Size(1, 1)
    $owner.Opacity = 0
    $owner.TopMost = $true
    $owner.Show()
    $owner.Activate()
    [System.Windows.Forms.Application]::DoEvents()

    $paneId = $env:HERDR_PANE_ID
    if ([string]::IsNullOrWhiteSpace($paneId)) {
        throw 'Herdr did not provide an active pane. Focus a pane and try again.'
    }

    $herdrBin = $env:HERDR_BIN_PATH
    if ([string]::IsNullOrWhiteSpace($herdrBin)) {
        $herdrCommand = Get-Command herdr.exe -ErrorAction SilentlyContinue
        if ($null -eq $herdrCommand) { $herdrCommand = Get-Command herdr -ErrorAction SilentlyContinue }
        if ($null -eq $herdrCommand) { throw 'Could not find the Herdr CLI.' }
        $herdrBin = $herdrCommand.Source
    }

    $agentInfo = & $herdrBin agent get $paneId 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "The active pane does not have a ready agent.`n$($agentInfo -join "`n")"
    }

    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Choose photo(s) for the active Herdr agent'
    $dialog.Filter = 'Image files|*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.webp;*.heic;*.heif;*.tif;*.tiff|All files|*.*'
    $dialog.Multiselect = $true
    $dialog.CheckFileExists = $true
    $dialog.RestoreDirectory = $true

    if ($dialog.ShowDialog($owner) -ne [System.Windows.Forms.DialogResult]::OK) { return }

    # Keep the text single-line: pane.send-text types literally and does not press Enter.
    $insertText = @($dialog.FileNames | ForEach-Object { '"' + $_ + '"' }) -join ' '
    $result = & $herdrBin pane send-text $paneId $insertText 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Could not insert the selected image path(s) into the active pane.`n$($result -join "`n")"
    }
} catch {
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        Show-PluginError $_.Exception.Message $owner
    } catch {
        [Console]::Error.WriteLine($_.Exception.Message)
        exit 1
    }
} finally {
    if ($null -ne $owner) {
        $owner.Close()
        $owner.Dispose()
    }
}