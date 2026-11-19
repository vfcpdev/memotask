param(
    [string]$Root = ".",
    [switch]$Strict
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path $Root).Path
$libDir = Join-Path $resolvedRoot "lib"

if (-not (Test-Path $libDir)) {
    Write-Error "No se encontro el directorio lib en: $resolvedRoot"
    exit 2
}

$dartFiles = Get-ChildItem -Path $libDir -Filter "*.dart" -Recurse | Where-Object {
    $_.Name -notlike "*.g.dart" -and $_.FullName -notmatch '[\\/]l10n[\\/]'
} | Sort-Object FullName

$findings = New-Object System.Collections.Generic.List[object]

function Add-Finding {
    param(
        [string]$Category,
        [string]$Severity,
        [string]$File,
        [int]$Line,
        [string]$Message
    )
    $findings.Add([PSCustomObject]@{
        Category = $Category
        Severity = $Severity
        File     = $File
        Line     = $Line
        Message  = $Message
    })
}

foreach ($file in $dartFiles) {
    $relPath = $file.FullName.Substring($resolvedRoot.Length + 1).Replace('\', '/')
    $lines = Get-Content -Path $file.FullName -Encoding UTF8
    $lineCount = $lines.Count

    $isDomain = $relPath -like "lib/domain/*"
    $isData = $relPath -like "lib/data/*"
    $isDataRepo = $relPath -like "lib/data/repositories/*"
    $isBloc = $relPath -like "lib/presentation/bloc/*"
    $isTheme = $relPath -like "lib/presentation/theme/*"
    $isPresentationUi = ($relPath -like "lib/presentation/screens/*" -or $relPath -like "lib/presentation/widgets/*" -or $relPath -eq "lib/app.dart")
    $isPresentation = ($relPath -like "lib/presentation/*" -or $relPath -eq "lib/app.dart")
    $isSrpTarget = ($relPath -like "lib/presentation/screens/*" -or $relPath -like "lib/presentation/widgets/*" -or $relPath -like "lib/domain/strategies/*" -or $relPath -like "lib/domain/usecases/*")

    $publicClassCount = 0
    $hasHoareP = $false
    $hasHoareC = $false
    $hasHoareQ = $false
    $hasConcreteLogic = $false

    for ($i = 0; $i -lt $lineCount; $i++) {
        $ln = $i + 1
        $text = $lines[$i]
        $trimmed = $text.Trim()

        # Skip pure comments for import/UI/SRP checks, but check Hoare markers first
        if ($text -match '//\s*\{P\}') { $hasHoareP = $true }
        if ($text -match '//\s*C\s+')  { $hasHoareC = $true }
        if ($text -match '//\s*\{Q\}') { $hasHoareQ = $true }

        if ($trimmed.StartsWith("//")) { continue }

        # 1. Layer Import Rules (ARCHITECTURE_RULES)
        if ($trimmed -match "^import\s+['""]([^'""]+)['""]") {
            $imp = $Matches[1]
            if ($isDomain) {
                if ($imp -match '^(package:flutter|package:drift|package:flutter_bloc)') {
                    Add-Finding "ARCHITECTURE" "BLOCKER" $relPath $ln "Domain no debe importar framework/persistencia: '$imp'"
                }
                if ($imp -match '(^|/)(data|presentation)/') {
                    Add-Finding "ARCHITECTURE" "BLOCKER" $relPath $ln "Domain no debe importar data/ o presentation/: '$imp'"
                }
            }
            elseif ($isBloc) {
                if ($imp -match '(^|/)data/') {
                    Add-Finding "ARCHITECTURE" "MAJOR" $relPath $ln "BLoC acoplado a capa data/ concreta (viola DIP): '$imp'"
                }
                if ($imp -eq 'package:flutter/material.dart') {
                    Add-Finding "ARCHITECTURE" "MINOR" $relPath $ln "BLoC no debe importar widgets de Material: '$imp'"
                }
            }
            elseif ($isPresentationUi -and $relPath -ne "lib/app.dart") {
                if ($imp -match '(^|/)data/' -or $imp -match '^package:drift') {
                    Add-Finding "ARCHITECTURE" "BLOCKER" $relPath $ln "UI/Presentation no debe importar data/ ni drift: '$imp'"
                }
                if ($imp -match 'strategies/.*_export_strategy\.dart') {
                    Add-Finding "ARCHITECTURE" "MAJOR" $relPath $ln "UI no debe importar estrategias concretas de exportacion: '$imp'"
                }
            }
            elseif ($isData) {
                if ($imp -match '(^|/)presentation/') {
                    Add-Finding "ARCHITECTURE" "BLOCKER" $relPath $ln "Data no debe importar presentation/: '$imp'"
                }
            }
        }

        # 2. UI Rules & Zero Hardcoding (UI_RULES)
        if ($isPresentation -and ($text -match '\.withOpacity\(')) {
            Add-Finding "UI_RULES" "MINOR" $relPath $ln "Uso deprecado de .withOpacity(); usar .withValues(alpha: ...)"
        }

        if ($isPresentationUi) {
            if ($text -match 'Color\(0x[0-9A-Fa-f]+\)') {
                Add-Finding "UI_RULES" "MAJOR" $relPath $ln "Color hexadecimal hardcoded fuera de lib/presentation/theme/"
            }
            if ($text -match '\bAppTheme\.(navy|lime|navySurface|onNavy|onLime)\b') {
                Add-Finding "UI_RULES" "MAJOR" $relPath $ln "Acceso estatico directo a AppTheme; usar Theme.of(context) / AppDesignTokens"
            }
            if ($text -match "\b(Text|SnackBar)\(\s*['""][^'""\$]{2,}['""]" -or $text -match "\b(labelText|tooltip|label)\s*:\s*['""][^'""\$]{2,}['""]") {
                Add-Finding "UI_RULES" "MAJOR" $relPath $ln "String literal de UI detectado (migrar a l10n/ARB)"
            }
        }

        # 3. SRP Public Class Count
        if ($isSrpTarget -and ($text -match '^\s*(abstract\s+|sealed\s+|final\s+|base\s+)?class\s+[A-Z][A-Za-z0-9_]*')) {
            $publicClassCount++
        }

        # Detect concrete business methods for Hoare coverage check (ignore pure Equatable props getters)
        if (($isDomain -or $isDataRepo -or $isBloc) -and ($text -match '^\s*(factory\s+|Future<|bool\s+|void\s+|List<|ExportResult\s+|ActivityScheduleSuccess\s+|ConflictReport\s+|Activity\s+|T\s+)')) {
            if ($trimmed -notmatch ';$' -and $trimmed -notmatch '^List<Object\??>\s+get\s+props') {
                $hasConcreteLogic = $true
            }
        }
    }

    if ($isSrpTarget -and $publicClassCount -gt 1) {
        Add-Finding "ARCHITECTURE_SRP" "MAJOR" $relPath 1 "$publicClassCount clases publicas en un mismo archivo (aplicar SRP por archivo)"
    }

    # 4. Hoare Triple Check (FORMAL_VERIFICATION)
    if (($isDomain -or $isDataRepo -or $isBloc) -and $hasConcreteLogic) {
        if (-not ($hasHoareP -and $hasHoareC -and $hasHoareQ)) {
            $missing = @()
            if (-not $hasHoareP) { $missing += "// {P}" }
            if (-not $hasHoareC) { $missing += "// C" }
            if (-not $hasHoareQ) { $missing += "// {Q}" }
            Add-Finding "FORMAL_VERIFICATION" "MAJOR" $relPath 1 ("Faltan marcadores de Tripla de Hoare estandarizados: " + ($missing -join ", "))
        }
    }
}

Write-Output "=== MemoTask Design-Control Audit ==="
Write-Output ("Archivos analizados: {0}" -f $dartFiles.Count)
Write-Output ("Hallazgos totales:   {0}" -f $findings.Count)
Write-Output ""

if ($findings.Count -gt 0) {
    $grouped = $findings | Group-Object Category
    foreach ($g in $grouped) {
        Write-Output ("[{0}] ({1})" -f $g.Name, $g.Count)
        foreach ($item in $g.Group) {
            Write-Output ("  - {0} | {1}:{2} | {3}" -f $item.Severity, $item.File, $item.Line, $item.Message)
        }
        Write-Output ""
    }
}
else {
    Write-Output "CONFORME: 0 violaciones detectadas."
}

if ($Strict -and $findings.Count -gt 0) {
    exit 1
}
exit 0
