# Proposed Migration Scaffolding Structure
The current structure is quite flat and lacks separation of concerns. 
Here is a recommended scaffolding approach. It is the most practical for XE8 migration while establishing clear boundaries. (It intentionaly does NOT use the more sophisticated "Onion Pattern").

``` text

simlabxray/
├── Core/                                # Business rules (no dependencies)
│   ├── Entities/
│   │   ├── uImage.pas
│   │   └── uImagingDevice.pas
│   ├── UseCases/                        # Application-specific business rules
│   │   ├── uCaptureImageUseCase.pas
│   │   ├── uUploadImageUseCase.pas
│   │   └── uListDevicesUseCase.pas
│   └── Interfaces/                      # Abstractions (no implementation)
│       ├── uIImageRepository.pas
│       ├── uIDeviceProvider.pas
│       └── uIUploadGateway.pas
│
├── Adapters/
│   ├── Drivers/                         # External interfaces
│   │   ├── uTwainDeviceAdapter.pas
│   │   ├── uSftpUploadAdapter.pas
│   │   └── uWindowsSystemAdapter.pas
│   ├── Controllers/                     # UI controllers / Presenters
│   │   ├── uMainFormPresenter.pas
│   │   └── uImageCaptureController.pas
│   └── Repositories/                    # Data access
│       └── uImageFileRepository.pas
│
├── Framework/                           # Framework-specific code (VCL)
│   ├── Forms/
│   │   ├── uMainForm.pas
│   │   ├── uMainForm.dfm
│   │   └── uDeviceListForm.pas
│   ├── Dependency Injection/
│   │   └── uDIContainer.pas
│   └── uApplication.pas                 # VCL app initialization
│
├── Shared/
│   ├── uLogger.pas
│   ├── uConfig.pas
│   └── uExceptions.pas
│
├── tests/
│   ├── Core/
│   │   ├── TestCaptureImageUseCase.pas
│   │   └── TestUploadImageUseCase.pas
│   └── Adapters/
│       └── TestSftpUploadAdapter.pas
│
└── docs/
    ├── Architecture.md
    └── Design_Patterns.md
```