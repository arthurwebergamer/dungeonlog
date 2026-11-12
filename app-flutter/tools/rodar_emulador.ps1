# Roda o app Flutter no emulador sem sujar o repositório com a pasta android/.
# Pré-requisitos (feitos uma vez): Flutter em C:\Users\User\flutter, Android SDK em C:\Users\User\Android\sdk,
# AVD "pixel_teste" e o projeto-casca em C:\Users\User\dungeonlog-runner (flutter create --platforms=android).
#
# Uso (PowerShell, a partir da raiz do repositório):  .\app-flutter\tools\rodar_emulador.ps1
param([string]$Comando = 'run')
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$origem = Join-Path $repo 'app-flutter'
$runner = 'C:\Users\User\dungeonlog-runner'
$flutter = 'C:\Users\User\flutter\bin\flutter.bat'

# espelha lib, assets, test e pubspec.yaml para o projeto-casca
foreach ($pasta in 'lib', 'assets', 'test') {
  robocopy (Join-Path $origem $pasta) (Join-Path $runner $pasta) /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
}
Copy-Item (Join-Path $origem 'pubspec.yaml') (Join-Path $runner 'pubspec.yaml') -Force

Push-Location $runner
try {
  & $flutter pub get
  if ($Comando -eq 'run') { & $flutter run -d emulator-5554 }
  elseif ($Comando -eq 'build') { & $flutter build apk --debug }
  else { & $flutter $Comando }
} finally { Pop-Location }
