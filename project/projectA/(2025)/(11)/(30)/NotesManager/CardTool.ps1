param(
  [Parameter(Position=0,Mandatory=$true)]
  [ValidateSet("validate")]
  [string]$Command,

  [Parameter()]
  [string]$CardPath
)

# === CONFIG ===
$Secret = "CHANGE_ME_TO_A_LONG_RANDOM_SECRET_32+_BYTES"

function Get-HmacSha256Base64 {
    param([byte[]]$Key,[byte[]]$Data)
    $h = New-Object System.Security.Cryptography.HMACSHA256
    $h.Key = $Key
    [Convert]::ToBase64String($h.ComputeHash($Data))
}
function Die([int]$code, [string]$msg) {
    Write-Error $msg
    exit $code
}

switch ($Command) {
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
}
