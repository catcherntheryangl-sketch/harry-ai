@echo off
title Harry A.I. — Push Electron Files to GitHub
color 0A

echo.
echo  ==========================================
echo   Harry A.I. — Push App Files to GitHub
echo   This adds Electron files to your repo
echo   GitHub Actions will then build the EXE
echo   automatically in the cloud
echo  ==========================================
echo.

set "DIR=%~dp0"
cd /d "%DIR%"

:: Check gh
gh auth status >nul 2>&1
if errorlevel 1 (
    echo  Logging into GitHub...
    gh auth login --web -h github.com
)

:: Set git identity (required for commits)
git config --global user.email "harry-ai@build.local" >nul 2>&1
git config --global user.name "Harry AI" >nul 2>&1

:: Copy HTML first
if exist "harry-ai.html" (
    copy /y "harry-ai.html" "index.html" >nul
    echo  index.html copied
)

:: Start fresh git repo
if exist ".git" rmdir /s /q ".git"
git init -b main
echo  Git initialized on branch main

:: Stage ALL files in this folder explicitly
git add .
echo  Files staged

:: Commit
git commit -m "Harry A.I. Electron app build"
echo  Files committed

:: Push to GitHub
git remote add origin "https://github.com/catcherntheryangl-sketch/harry-ai.git"
git push -u origin main --force

echo.
echo  ==========================================
echo   Files pushed to GitHub!
echo  ==========================================
echo.
echo   GitHub Actions is now building your EXE.
echo   Takes about 5 minutes in the cloud.
echo.
echo   Watch progress here:
echo   https://github.com/catcherntheryangl-sketch/harry-ai/actions
echo.
echo   Download your EXE from here when done:
echo   https://github.com/catcherntheryangl-sketch/harry-ai/releases
echo.
start "" "https://github.com/catcherntheryangl-sketch/harry-ai/actions"
pause
