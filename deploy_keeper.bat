@echo off
setlocal

ECHO =======================================
ECHO KEEPER BUILD AND DEPLOYMENT SCRIPT
ECHO =======================================

REM --- Part 1: Build Release APK for arm64-v8a ---
ECHO.
ECHO =======================================
ECHO 1. Building Android APK (arm64-v8a release)
ECHO =======================================
flutter build apk --release --target-platform=android-arm64
IF ERRORLEVEL 1 (
    ECHO Error building APK. Please check the Flutter output above.
    GOTO :EOF
)
ECHO APK build complete.

REM --- Part 2: Copy the APK to a specified location ---
ECHO.
ECHO =======================================
ECHO 2. Copying APK to destination
ECHO =======================================
SET /P APK_DEST_PATH="Enter the full destination path for the APK (e.g., C:\Users\YourUser\Downloads\keeper_apks\): "
IF NOT DEFINED APK_DEST_PATH (
    ECHO Error: APK destination path cannot be empty. Exiting.
    GOTO :EOF
)

REM Ensure the destination directory exists
IF NOT EXIST "%APK_DEST_PATH%\" (
    ECHO Destination path "%APK_DEST_PATH%" does not exist. Creating it.
    mkdir "%APK_DEST_PATH%"
    IF ERRORLEVEL 1 (
        ECHO Failed to create directory "%APK_DEST_PATH%". Exiting.
        GOTO :EOF
    )
)

SET "APK_SOURCE=build\app\outputs\flutter-apk\app-release.apk"
IF NOT EXIST "%APK_SOURCE%" (
    ECHO Error: APK file not found at "%APK_SOURCE%". Exiting.
    GOTO :EOF
)
copy "%APK_SOURCE%" "%APK_DEST_PATH%\"
IF ERRORLEVEL 1 (
    ECHO Error copying APK. Exiting.
    GOTO :EOF
)
ECHO APK copied to: %APK_DEST_PATH%\app-release.apk

REM --- Part 3: Deploy Web App to GitHub Pages ---
ECHO.
ECHO =======================================
ECHO 3. Building Flutter Web App for GitHub Pages
ECHO =======================================
flutter build web --release --base-href /keeper/
IF ERRORLEVEL 1 (
    ECHO Error building web app. Please check the Flutter output above.
    GOTO :EOF
)
ECHO Web build complete.

ECHO.
ECHO =======================================
ECHO 4. Copying Web App to docs folder
ECHO =======================================
xcopy /E /I /Y build\web docs
IF ERRORLEVEL 1 (
    ECHO Error copying web files to docs folder. Exiting.
    GOTO :EOF
)
ECHO Web files copied to docs folder.

ECHO.
ECHO =======================================
ECHO 5. Staging, Committing, and Pushing to GitHub
ECHO =======================================
git add docs
IF ERRORLEVEL 1 (
    ECHO Error adding docs to git. Exiting.
    GOTO :EOF
)
git commit -m "Automated build and web deploy update"
IF ERRORLEVEL 1 (
    ECHO Error committing changes. This might happen if there are no changes to commit.
    REM Continue to push even if commit fails due to no changes
)
git push origin main
IF ERRORLEVEL 1 (
    ECHO Error pushing to GitHub. Please check your Git credentials/connection.
    GOTO :EOF
)
ECHO Changes pushed to GitHub. Web app will update shortly.

ECHO.
ECHO =======================================
ECHO SCRIPT COMPLETE
ECHO =======================================
pause
endlocal 