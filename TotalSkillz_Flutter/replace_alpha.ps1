Get-ChildItem -Path lib -Recurse -Filter *.dart | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '\.withValues\(alpha:\s*([0-9.]+)\)') {
        $newContent = $content -replace '\.withValues\(alpha:\s*([0-9.]+)\)', '.withOpacity($1)'
        Set-Content -Path $_.FullName -Value $newContent -NoNewline
        Write-Host "Updated $($_.FullName)"
    }
}
