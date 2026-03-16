@echo off
title Harry A.I. — Build Windows App
color 0A
setlocal enabledelayedexpansion

echo.
echo  ==========================================
echo   Harry A.I. — Windows App Builder
echo   Builds HarryAI-Setup.exe + pushes to
echo   GitHub so it auto-downloads from repo
echo  ==========================================
echo.

:: ── Get folder of this bat file ───────────────────────
set "DIR=%~dp0"
cd /d "%DIR%"

:: ── Step 1: Check Node.js ─────────────────────────────
echo [1/6] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo  Node.js not found. Installing...
    winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements
    :: Refresh PATH
    for /f "delims=" %%i in ('where node 2^>nul') do set "NODE_PATH=%%~dpi"
    set "PATH=%PATH%;%NODE_PATH%"
)
for /f "tokens=*" %%v in ('node --version 2^>nul') do echo  Node.js %%v ready
echo.

:: ── Step 2: Check harry-ai.html ───────────────────────
echo [2/6] Checking app file...
if not exist "harry-ai.html" (
    echo  ERROR: harry-ai.html not found in this folder.
    echo  Put harry-ai.html and build.bat in the same folder.
    pause & exit /b 1
)
copy /y "harry-ai.html" "index.html" >nul
echo  index.html ready
echo.

:: ── Step 3: Create icon ───────────────────────────────
echo [3/6] Setting up icon...
:: Generate a simple ICO using PowerShell if no icon exists
if not exist "icon.ico" (
    powershell -NoProfile -Command ^
        "$size=256; $bmp=New-Object System.Drawing.Bitmap($size,$size); $g=[System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::FromArgb(7,7,12)); $brush=New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(108,99,255)); $font=New-Object System.Drawing.Font('Arial',80,[System.Drawing.FontStyle]::Bold); $g.DrawString('H',$font,$brush,60,70); $bmp.Save('icon.ico',[System.Drawing.Imaging.ImageFormat]::Icon); $g.Dispose(); $bmp.Dispose()" ^
        2>nul
    if not exist "icon.ico" (
        :: Fallback: copy any existing ico or skip
        echo  No icon.ico found - using default Electron icon
    ) else (
        echo  icon.ico created
    )
) else (
    echo  icon.ico found
)
echo.

:: ── Step 4: npm install ───────────────────────────────
echo [4/6] Installing Electron (first time takes 2-3 min)...
if not exist "node_modules" (
    call npm install --silent
    if errorlevel 1 (
        echo  npm install failed. Check your internet connection.
        pause & exit /b 1
    )
) else (
    echo  node_modules already installed
)
echo.

:: ── Step 5: Build EXE ────────────────────────────────
echo [5/6] Building HarryAI-Setup.exe...
echo  This takes 2-5 minutes...
call npm run build
if errorlevel 1 (
    echo.
    echo  Build failed. Common fixes:
    echo  - Run as Administrator (right-click build.bat)
    echo  - Check antivirus isn't blocking electron-builder
    echo  - Make sure you have internet for downloading Electron
    pause & exit /b 1
)
echo.
echo  Build complete!
echo.

:: ── Step 6: Push to GitHub ───────────────────────────
echo [6/6] Pushing to GitHub...

gh auth status >nul 2>&1
if errorlevel 1 (
    echo  Logging into GitHub...
    gh auth login --web -h github.com
)

:: Init git if needed
if not exist ".git" (
    git init -q
    git branch -M main
)

:: Add all files
git add package.json main.js index.html harry-ai.html >nul 2>&1

:: Add the built exe if it exists
if exist "dist\HarryAI-Setup.exe" (
    git add "dist\HarryAI-Setup.exe" >nul 2>&1
    echo  EXE found: dist\HarryAI-Setup.exe
)

git commit -q -m "Harry A.I. Windows app build" >nul 2>&1

:: Push to existing repo
git remote remove origin >nul 2>&1
git remote add origin "https://github.com/catcherntheryangl-sketch/harry-ai.git"
git push -u origin main --force -q
if errorlevel 1 (
    echo  Push failed - check GitHub login
) else (
    echo  Pushed to GitHub
)

:: ── Done ──────────────────────────────────────────────
echo.
echo  ==========================================
echo   DONE!
echo  ==========================================
echo.

if exist "dist\HarryAI-Setup.exe" (
    echo   EXE location:
    echo   %DIR%dist\HarryAI-Setup.exe
    echo.
    echo   Opening dist folder...
    explorer "%DIR%dist"
) else (
    echo   Check the dist\ folder for your EXE
)
echo.
echo   GitHub repo:
echo   https://github.com/catcherntheryangl-sketch/harry-ai
echo.
echo   Live web app:
echo   https://catcherntheryangl-sketch.github.io/harry-ai
echo.
pause
