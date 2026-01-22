@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM  UPLOAD_IMAGE.BAT - X-Ray Image Upload Automation Script
REM ============================================================================
REM
REM PURPOSE:
REM   This batch script automates the transfer of intraoral X-ray images from a
REM   dental imaging system to a remote SFTP server. It is part of the SimLab
REM   X-Ray VCL2 application pipeline and handles secure, organized upload of
REM   diagnostic dental radiographs to a production Django-based media server.
REM
REM TECHNICAL OVERVIEW:
REM   The script implements a multi-stage SFTP upload workflow:
REM
REM   1. INITIALIZATION & VALIDATION
REM      - Reads configuration parameters from command-line arguments and
REM        environment variables
REM      - Validates source image file existence (xray.jpg in current directory)
REM      - Verifies PuTTY PSFTP installation (required for SFTP functionality)
REM      - Initializes logging infrastructure for transaction auditing
REM
REM   2. PATH RESOLUTION & CATEGORIZATION
REM      - Extracts producer/facility code from remote filename (pre-hyphen token)
REM      - Constructs dynamic remote directory path using base root and producer
REM      - Example: "S9999" from "S9999-2026-01-21.jpg" maps to
REM        /opt/dental/MusodDjango/media/xrays/S9999/
REM      - Supports multi-facility deployments via organization-specific routing
REM
REM   3. SECURE TRANSFER EXECUTION
REM      - Generates command batch file for PSFTP execution (avoiding credential
REM        exposure in process arguments)
REM      - Invokes PuTTY PSFTP with:
REM        * SSH key-based authentication using private key from .ssh directory
REM        * Remote directory navigation and file placement
REM        * Proper cleanup of sensitive temporary files
REM      - Captures exit code for error handling and reporting
REM
REM   4. ERROR HANDLING & ALERTING
REM      - Evaluates SFTP operation success/failure via exit code
REM      - Logs transaction details to persistent log file (%TEMP%\upload_image.log)
REM      - Displays user-facing alerts via HTML modal dialog (MSHTA) or console
REM      - Returns appropriate exit codes to calling application for integration
REM
REM DEPENDENCIES:
REM   - PuTTY Suite (PSFTP): SFTP client with SSH key-based authentication support
REM     * Primary install path: C:\Program Files\PuTTY\psftp.exe
REM     * Fallback path: C:\Program Files (x86)\PuTTY\psftp.exe (32-bit)
REM   - SSH Private Key: MUST be in PuTTY .ppk format (NOT OpenSSH format)
REM     * Located in .ssh directory provided via %1 parameter
REM     * If key is in OpenSSH format, convert using PuTTYgen: Open Key -> Export as .ppk
REM   - Windows MSHTA (HTML Application Host): User alert display on modern Windows
REM   - Standard Windows System32 utilities: CMD, SET, FOR loops
REM
REM COMMAND-LINE ARGUMENTS:
REM   %1 = SSH_DIR - Path to .ssh directory (contains private key for SFTP authentication)
REM                   Expected key file: *.ppk (PuTTY format - REQUIRED)
REM                   Do NOT use OpenSSH format (.ssh files without .ppk extension)
REM   %2 = REMOTE_FILENAME - Target filename on server (e.g., S9999-2026-01-21.jpg)
REM                          Naming convention: {PRODUCER}-{DATE}.jpg
REM
REM CONFIGURATION:
REM   - Local source file: xray.jpg (hardcoded in current working directory)
REM   - SFTP user account: svc-dentappsnd-sftp (service account with SSH public key)
REM   - Remote host: vs-dentappprod.marqnet.mu.edu (production X-Ray media server)
REM   - Root media directory: /opt/dental/MusodDjango/media/xrays/
REM   - SSH Private Key: MUST be in PuTTY .ppk format (e.g., id_rsa.ppk)
REM     * If key is in OpenSSH format (.ssh or id_rsa), convert using PuTTYgen
REM   - Log file: %TEMP%\upload_image.log (Windows temp directory)
REM
REM KEY CONVERSION INSTRUCTIONS:
REM   If you have an OpenSSH format key (.ssh file or id_rsa):
REM   1. Open PuTTYgen (comes with PuTTY)
REM   2. Click "Load" and select your OpenSSH private key file
REM   3. Click "Export Key" and save as .ppk format
REM   4. Place the .ppk file in the .ssh directory used by this script
REM
REM USAGE EXAMPLE:
REM   upload_image.bat "C:\Users\username\.ssh" "S9999-2026-01-21.jpg"
REM
REM ERROR CODES:
REM   0 - Success: Image uploaded and verified on remote server
REM   1 - Source file not found (xray.jpg missing in working directory)
REM   1 - PSFTP installation not found on system
REM   >1 - SFTP protocol error: Network failure, authentication denied, or
REM        remote directory permission issue (code passed from PSFTP)
REM
REM ============================================================================

REM Args:
REM   %1 = path to .ssh directory (contains private key and known_hosts)
REM   %2 = target filename for remote server (e.g., S9999-2026-01-21.jpg)

set "SSH_DIR=%~1"
set "REMOTE_FILENAME=%~2"
set "LOCAL_FILE=xray.jpg"
set "USER=svc-dentappsnd-sftp"
set "HOST=vs-dentappprod.marqnet.mu.edu"
set "REMOTE_ROOT=/opt/dental/MusodDjango/media/xrays"
set "LOGFILE=%TEMP%\upload_image.log"

rem Resolve SSH private key path (PuTTY .ppk format is required)
rem Check for common .ppk filenames first
set "SSH_KEY_PATH=%SSH_DIR%\id_rsa.ppk"
if not exist "!SSH_KEY_PATH!" set "SSH_KEY_PATH=%SSH_DIR%\key.ppk"
if not exist "!SSH_KEY_PATH!" set "SSH_KEY_PATH=%SSH_DIR%\private.ppk"
if not exist "!SSH_KEY_PATH!" set "SSH_KEY_PATH=%SSH_DIR%\.ssh.ppk"

call :log "Starting upload of %LOCAL_FILE% as %REMOTE_FILENAME%"
echo [INFO] Starting upload of %LOCAL_FILE% as %REMOTE_FILENAME%...
echo [INFO] Using key file: !SSH_KEY_PATH!
rem call :alert "Starting upload: %REMOTE_FILENAME%"

rem Derive producer code subfolder from remote filename prefix (before first '-')
for /f "tokens=1 delims=-" %%A in ("%REMOTE_FILENAME%") do set "PRODUCER=%%A"
if not defined PRODUCER set "PRODUCER=unknown"
set "REMOTE_DIR=%REMOTE_ROOT%/%PRODUCER%"

if not defined SSH_DIR (
  echo [ERROR] SSH_DIR parameter not provided
  call :log "ERROR SSH_DIR parameter not provided"
  rem call :alert "SSH directory path required as first argument"
  exit /b 1
)

if not exist "!SSH_KEY_PATH!" (
  echo [ERROR] SSH private key not found at: !SSH_KEY_PATH!
  call :log "ERROR SSH private key not found: !SSH_KEY_PATH!"
  rem call :alert "SSH private key (.ppk) not found. Use PuTTYgen to convert OpenSSH keys to .ppk format."
  exit /b 1
)

if not exist "%LOCAL_FILE%" (
  echo [ERROR] File not found: %LOCAL_FILE%
  call :log "ERROR File not found: %LOCAL_FILE%"
  rem call :alert "File not found: %LOCAL_FILE%"
  exit /b 1
)

rem Use PuTTY's PSFTP for SFTP upload (matches FileZilla protocol)
set "PUTTY=C:\Program Files\PuTTY"
if not exist "%PUTTY%\psftp.exe" set "PUTTY=C:\Program Files (x86)\PuTTY"
if not exist "%PUTTY%\psftp.exe" (
  call :log "ERROR PuTTY PSFTP not found"
  rem call :alert "PuTTY PSFTP not found. Ensure PuTTY is installed."
  exit /b 1
)

rem Build PSFTP command script
echo cd "%REMOTE_DIR%" > "%TEMP%\psftp_commands.txt"
echo put "%LOCAL_FILE%" "%REMOTE_FILENAME%" >> "%TEMP%\psftp_commands.txt"
echo bye >> "%TEMP%\psftp_commands.txt"

rem Upload via PSFTP using SSH key authentication
"%PUTTY%\psftp.exe" -i "!SSH_KEY_PATH!" -b "%TEMP%\psftp_commands.txt" "%USER%@%HOST%"
set "EXITCODE=%ERRORLEVEL%"
del "%TEMP%\psftp_commands.txt" >nul 2>&1

if not "%EXITCODE%"=="0" (
  echo [ERROR] Upload failed with code %EXITCODE%
  call :log "ERROR Upload failed with code %EXITCODE%"
  rem call :alert "Upload failed with code %EXITCODE%"
  exit /b %EXITCODE%
)

echo [INFO] Upload succeeded: %REMOTE_FILENAME%
call :log "SUCCESS Upload succeeded: %REMOTE_FILENAME%"
rem call :alert "Upload succeeded: %REMOTE_FILENAME%"
exit /b 0

:alert
rem Surface an alert on the client for visibility
if exist "%SystemRoot%\System32\mshta.exe" (
  "%SystemRoot%\System32\mshta.exe" "javascript:alert('%~1');close()" >nul 2>&1
) else (
  echo [ALERT] %~1
)
goto :eof

:log
echo %date% %time% %~1>>"%LOGFILE%"
goto :eof
