$ErrorActionPreference = 'Stop'
$manifest = Join-Path $PSScriptRoot '..\android\app\src\main\AndroidManifest.xml'
if (-not (Test-Path $manifest)) {
    throw 'No existe AndroidManifest.xml. Ejecuta primero flutter create --platforms=android .'
}
$xml = Get-Content -Path $manifest -Raw -Encoding UTF8
if ($xml -notmatch 'android.permission.RECORD_AUDIO') {
    $permisos = @'

    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <queries>
        <intent>
            <action android:name="android.speech.RecognitionService" />
        </intent>
        <intent>
            <action android:name="android.intent.action.TTS_SERVICE" />
        </intent>
    </queries>
'@
    $xml = [regex]::Replace($xml, '(<manifest\b[^>]*>)', ('$1' + $permisos), 1)
    Set-Content -Path $manifest -Value $xml -Encoding UTF8
}
Write-Host 'Permisos de microfono, Internet y consultas de voz configurados.' -ForegroundColor Green
