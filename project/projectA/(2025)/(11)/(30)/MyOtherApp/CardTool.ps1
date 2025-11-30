param(
  [Parameter(Position=0,Mandatory=$true)]
  [ValidateSet("generate","validate")]
  [string]$Command,

  [Parameter()]
  [string]$TesterId,

  [Parameter()]
  [int]$DaysValid = 365,

  [Parameter()]
  [string]$OutPath,

  [Parameter()]
  [string]$CardPath
)

# === CONFIG ===
# Replace this with a long random secret string (32+ characters).
$Secret = "CHANGE_ME_TO_A_LONG_RANDOM_SECRET_32+_BYTES"

# === UTILITIES ===
function Get-HmacSha256Base64 {
    param([byte[]]$Key,[byte[]]$Data)
    $h = New-Object System.Security.Cryptography.HMACSHA256
    $h.Key = $Key
    [Convert]::ToBase64String($h.ComputeHash($Data))
}
function ToBase64([string]$text) {
    [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($text))
}
function Die([int]$code, [string]$msg) {
    Write-Error $msg
    exit $code
}

# === ID GENERATOR (NNLL–NNLLN) ===
function New-CustomerId {
    $digits1 = -join ((0..9) | Get-Random -Count 2)
    $letters1 = -join ((65..90) | Get-Random -Count 2 | ForEach-Object {[char]$_})
    $digits2 = -join ((0..9) | Get-Random -Count 2)
    $letters2 = -join ((65..90) | Get-Random -Count 2 | ForEach-Object {[char]$_})
    $digit3 = Get-Random -Minimum 0 -Maximum 10
    return "$digits1$letters1-$digits2$letters2$digit3"
}

# === COMMANDS ===
switch ($Command) {

  "generate" {
    if (-not $TesterId) { Die 10 "Missing -TesterId"; }
    if (-not $OutPath)  { $OutPath = Join-Path $env:USERPROFILE\Desktop "$TesterId.vcard" }

    $issued  = [DateTime]::UtcNow
    $expires = $issued.AddDays($DaysValid)
    $customerId = New-CustomerId

    $fields = [ordered]@{
      testerId   = $TesterId
      customerId = $customerId
      issuedAt   = $issued.ToString("o")
      expiresAt  = $expires.ToString("o")
    }

    $payloadJson = (ConvertTo-Json $fields -Depth 4)
    $payloadB64  = ToBase64 $payloadJson

    $secretBytes = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    $dataBytes   = [Convert]::FromBase64String($payloadB64)
    $signature   = Get-HmacSha256Base64 -Key $secretBytes -Data $dataBytes

    $card = [ordered]@{
      testerId   = $TesterId
      customerId = $customerId
      issuedAt   = $fields.issuedAt
      expiresAt  = $fields.expiresAt
      payload    = $payloadB64
      signature  = $signature
      format     = "vcard-hmac-sha256-v1"
    }

    $card | ConvertTo-Json -Depth 6 | Set-Content -Path $OutPath -Encoding UTF8
    Write-Host "Card created:"
    Write-Host "  Tester ID  : $TesterId"
    Write-Host "  Customer ID: $customerId"
    Write-Host "  Issued     : $($fields.issuedAt)"
    Write-Host "  Expires    : $($fields.expiresAt)"
    Write-Host "  File       : $OutPath"
    exit 0
  }

  "validate" {
    if (-not $CardPath) { Die 10 "Missing -CardPath"; }
    if (-not (Test-Path $CardPath)) { Die 2 "Card file not found: $CardPath"; }

    try {
      $card = Get-Content -Path $CardPath -Raw | ConvertFrom-Json
    } catch {
      Die 3 "Invalid card format (JSON parse failed)."
    }

    if (-not $card.payload -or -not $card.signature -or -not $card.expiresAt -or -not $card.testerId) {
      Die 4 "Card missing required fields."
    }

    $secretBytes = [System.Text.Encoding]::UTF8.GetBytes($Secret)
    try {
      $dataBytes = [Convert]::FromBase64String($card.payload)
    } catch {
      Die 4 "Card payload invalid base64."
    }
    $sig = Get-HmacSha256Base64 -Key $secretBytes -Data $dataBytes
    if ($sig -ne $card.signature) {
      Die 5 "Signature mismatch. Card appears tampered."
    }

    try {
      $exp = [DateTime]::Parse($card.expiresAt)
    } catch {
      Die 4 "Invalid expiration format."
    }

    if ([DateTime]::UtcNow -gt $exp.ToUniversalTime()) {
      Die 7 "Card expired on $($exp.ToString('o'))."
    }

    Write-Host "Card is valid. Tester: $($card.testerId) | Customer ID: $($card.customerId) | Expires: $($exp.ToString('u'))"
    exit 0
  }

} # closes switch
