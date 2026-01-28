# SimLab X-Ray VCL2 - Dental Imaging Application

## Overview

**SimLab X-Ray VCL2** is a Windows-based desktop application for capturing, managing, and uploading intraoral X-ray images from dental imaging workstations. It integrates with TWAIN-compliant imaging devices (scanners, digital sensors) and provides secure automated upload to a remote Django-based media server.

## Purpose & Use Cases

This application is designed for dental imaging workflows where:
- **Image Capture**: Acquire intraoral X-ray images directly from TWAIN devices (digital sensors, scanners)
- **Local Management**: Preview, save, and organize images locally
- **Secure Upload**: Automatically upload captured images to a centralized server with facility-based organization
- **Audit Trail**: Maintain logs of all imaging and upload operations for compliance

## Key Features

### Core Functionality
- **TWAIN Device Integration**: Connect to any TWAIN-compliant imaging device
- **Multiple Device Support**: Select from available imaging sources (scanners, sensors, cameras)
- **Image Capture**: Acquire images with or without system dialogs
- **JPEG Compression**: Save and manage images in standard JPEG format
- **Facility-Based Organization**: Organize images by producer/facility codes for multi-location deployments

### Secure Image Transfer
- **SSH Key Authentication**: Uses PuTTY PSFTP with SSH keys (no password authentication)
- **Automated Upload**: Batch upload images to remote server via SFTP
- **Error Handling**: Comprehensive logging and error reporting for upload operations
- **Network Resilience**: Handle network timeouts and connection failures gracefully

## Technology Stack

| Component | Details |
|-----------|---------|
| **Language** | Object Pascal (Delphi) |
| **Framework** | VCL (Visual Component Library) |
| **Delphi Version** | XE8 (2016 / Version 19.3) |
| **Target OS** | Windows 10/11 (32-bit & 64-bit) |
| **Image API** | TWAIN (scanner/device integration) |
| **Network Transfer** | SFTP via PuTTY PSFTP |
| **Key Libraries** | Indy (network), JPEG imaging, DelphiTwain |

## Project Structure
(NOT exhaustive)

```
simlabxray/
├── README.md                          # This file
├── Image_Upload_README.md             # Detailed image upload configuration guide
├── Delphi_Migration_Notes.md          # Version upgrade considerations
├── Delphi_Migration_Scaffold.md       # Version upgrade scaffolding option
├── simlabxray.dpr                     # Main application entry point
├── simlabxray.dproj                   # Delphi project file
├── Unit1.pas / Unit1.dfm              # Main application form
├── DelphiTwain*.pas                   # TWAIN device integration
├── upload_image.bat                   # SFTP upload script
├── ssh_keys/                          # SSH authentication keys
├── Win32/ & Win64/                    # Compiled binaries
└── __history/                         # Delphi backup versions
```

[Proposed Migration Scaffold Structure](\docs\Delphi_Migration_Scaffold.md)

## Getting Started

### Development Requirements
- **Delphi XE8** or compatible version
- **PuTTY Suite** (for SFTP client)
- **SSH Keys** configured for server authentication
- **TWAIN-compliant device** for image capture

### Building the Application
1. Open `simlabxray.dproj` in Delphi XE8
2. Build for Win32 or Win64 platform
3. Output executable will be in `Win32\Release\` or `Win64\Release\`

### Running the Application
1. Ensure a TWAIN device is installed and working
2. Configure SSH keys in the `ssh_keys/` directory (see [Image_Upload_README.md](\docs\Image_Upload_README.md))
3. Launch `simlabxray.exe`
4. Select imaging device from available sources
5. Capture image and configure upload parameters
6. Images will be transferred to server via the upload_image.bat script

## Configuration

### Image Upload Setup
Complete setup instructions including SSH key configuration, server-side requirements, and troubleshooting are documented in [Image_Upload_README.md](docs\Image_Upload_README.md).

### Key Configuration Parameters
- **TWAIN Device Selection**: Choose from available imaging sources in the application UI
- **Producer/Facility Code**: Prefix for organizing images on the server
- **SFTP Credentials**: SSH key-based authentication (see Image_Upload_README.md)
- **Upload Directory**: Server destination path for captured images

## Maintenance & Upgrades

### Current Version
- Delphi XE8 (2016)
- Windows 10/11 compatible

### Architecture & Refactoring
The current project has a flat structure. For a more maintainable, modern architecture suitable for Delphi migration, see [Delphi_Migration_Scaffold.md](\docs\Delphi_Migration_Scaffold.md), which proposes layered architecture patterns and a recommended migration path.

### Migration Path
For information about upgrading to newer Delphi versions, see [Delphi_Migration_Notes.md](\docs\Delphi_Migration_Notes.md).

## Documentation

- **[Image_Upload_README.md](\docs\Image_Upload_README.md)** - Complete SFTP upload configuration guide
- **[Delphi_Migration_Notes.md](\docs\Delphi_Migration_Notes.md)** - Version upgrade considerations
- **[Proposed Migration Scaffold Structure](\docs\Delphi_Migration_Scaffold.md)** - Architextural Structuring Option

## Support & Development

This project was inherited from a previous developer. Key maintainers should:
1. Familiarize themselves with TWAIN device integration
2. Test device compatibility across Windows versions
3. Review SSH/SFTP security configuration
4. Monitor PuTTY and dependent library updates

## License

[Specify license if applicable]

## Notes

- TWAIN library is dynamically loaded to prevent hangs if devices are unavailable
- Application supports both VCL and FMX frameworks (FMX variants available in code)
- Comprehensive logging enables audit trails for compliance requirements

## Operational Requirements

### Required presence of the log file (log.txt)
A log.txt file must be in existance in the root directory along with the .exe file.
Its absence with generate a "file not found" error message and halt the upload process.

### Student List Data File (simlablist.csv)

The application requires a CSV file (`simlablist.csv`) containing the current student roster with their card numbers and producer codes for the scanner. This file is **required** for the application to function properly.

#### File Generation & Placement

1. **Generate the file** using the server-side script: `generate_simlab_student_list_csv.py`
   - Located on the main server
   - Takes one required parameter: the graduating year of the student class (e.g., `2028`)
   - Example: `python generate_simlab_student_list_csv.py 2028`

2. **Deploy the generated file** to the S drive:
   - **Path**: `S:\Delphi\simlabxrays\simlablist.csv`
   - This location must be accessible to the workstation running this application

#### File Contents

The CSV file contains five columns:
- Card number (for scanner identification)
- Producer code (facility/location identifier)
- Student full name (last, first)
- Student last name
- Student first name

In addition to the student records, 5 additional "Test" records are added for temp card usage
- Simlab Card A - Simlab Card #

#### Maintenance

- Regenerate and update `simlablist.csv` annually or as needed when student cohorts change
- Ensure the S drive path remains accessible to all workstations running this application
- Store historical versions of the file if audit trail is required
