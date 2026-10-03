# 🖥️ Computer Hardware Upgrade Advisor

> 🔒 **PROPRIETARY SOFTWARE — NOT OPEN SOURCE**
> Copyright © 2026 VALOR. All Rights Reserved.

A Windows PowerShell-based **computer hardware analysis and upgrade recommendation tool** designed to inspect a system's current hardware configuration and provide general upgrade guidance.

The application analyzes CPU, RAM, GPU, motherboard, and storage information, performs basic bottleneck assessment, provides upgrade recommendations, generates TXT/CSV reports, and maintains local application logs.

---

## ✨ Features

### 🔍 1. Analyze Current Hardware

The application collects and displays available system information including:

* Computer name
* Operating system
* Windows version
* Windows build
* CPU model
* CPU manufacturer
* CPU cores
* Logical processors
* Maximum CPU clock speed
* CPU socket
* Installed RAM
* Number of RAM modules
* RAM speed
* Motherboard manufacturer
* Motherboard model
* GPU model
* GPU memory
* Total storage capacity
* Available storage
* Used storage

Hardware information is collected using Windows system-management interfaces such as CIM/WMI.

---

## 🧠 2. CPU Upgrade Recommendations

Provides CPU upgrade suggestions based on the detected CPU manufacturer.

The application presents example recommendations for:

* Gaming and general use
* Content creation and streaming
* Budget-oriented upgrades

The application also displays compatibility reminders regarding:

* CPU socket
* BIOS support
* Power requirements
* Motherboard compatibility

> CPU recommendations are general guidance. The application does not automatically guarantee compatibility with every motherboard or system.

---

## 💾 3. RAM Upgrade Recommendations

Analyzes the currently installed RAM capacity and provides upgrade guidance.

The application considers:

* Total RAM
* Number of memory modules
* RAM speed

The tool provides general memory recommendations for workloads such as:

* General computing
* Gaming
* Content creation
* Video editing
* 3D workloads

> Actual RAM compatibility depends on the motherboard, memory generation, supported capacity, slot configuration, and other hardware limitations.

---

## 💽 4. Storage Upgrade Recommendations

Analyzes available storage capacity and calculates storage utilization.

The tool provides warnings when storage usage becomes high and presents example upgrade paths such as:

* NVMe SSD
* SATA SSD
* Larger-capacity SSD

Storage usage is presented as:

* Total capacity
* Used capacity
* Free capacity
* Percentage used

> Storage recommendations are general guidance and do not automatically determine the physical interface, slot availability, PCIe generation, or motherboard compatibility.

---

## 🎮 5. GPU Upgrade Recommendations

Provides example graphics-card upgrade recommendations for different workloads, including:

* 1440p gaming
* 4K gaming
* Content creation
* Budget configurations

The application also displays:

* Current GPU
* Detected GPU memory

> GPU recommendations are reference suggestions and do not guarantee gaming performance, application performance, power compatibility, physical clearance, or suitability for a particular workload.

---

## 🧩 6. Motherboard Compatibility Check

Provides a manual compatibility-verification workflow.

The application instructs the user to:

1. Visit the motherboard manufacturer's website.
2. Search for the motherboard model.
3. Review the supported CPU list.
4. Check required BIOS versions.
5. Verify available BIOS updates.

This approach intentionally directs the user to manufacturer documentation rather than presenting an automatic compatibility result as guaranteed.

---

## ⚙️ 7. Detect Bottlenecks

Performs a basic system-level assessment using detected hardware information.

The current implementation evaluates:

* CPU characteristics
* RAM capacity
* RAM speed
* Storage utilization

The application generates informational indicators such as:

* CPU performance concern
* Moderate CPU concern
* RAM capacity concern
* Storage usage concern
* Adequate configuration

> Bottleneck detection is **heuristic**. It is not a benchmark, stress test, FPS analyzer, workload profiler, or professional performance-testing system.

Actual bottlenecks can vary depending on:

* Applications
* Games
* Drivers
* GPU workload
* CPU workload
* Thermals
* Power limits
* Memory configuration
* Storage type
* System configuration

---

## 📊 8. Overall System Upgrade Plan

Generates a general multi-stage upgrade plan based on the current system profile.

The application presents upgrade phases such as:

### Phase 1 — Immediate

Example areas:

* RAM
* Storage

### Phase 2 — Medium Term

Example area:

* CPU platform upgrade

### Phase 3 — Optional / Long Term

Example area:

* GPU upgrade for gaming or rendering workloads

The tool also presents example budget ranges.

> Upgrade phases and budget figures are built-in guidance and should not be treated as live market pricing or guaranteed performance improvements.

---

# 📄 9. Generate TXT Upgrade Report

Creates a human-readable hardware upgrade report containing information such as:

* Computer information
* Operating system
* CPU
* RAM
* Storage
* GPU
* Motherboard
* Upgrade recommendations
* Compatibility notes
* Estimated upgrade investment

The report is saved to the user's Desktop when available.

Example filename:

```text
UpgradeReport_YYYY-MM-DD_HHmmss.txt
```

---

# 📊 10. Generate CSV Upgrade Report

Creates structured CSV data containing hardware and recommendation information.

The CSV can be opened using:

* Microsoft Excel
* LibreOffice Calc
* Google Sheets
* Other CSV-compatible software

Example filename:

```text
UpgradeReport_YYYY-MM-DD_HHmmss.csv
```

---

# 📝 11. View Logs

The application maintains local activity logs.

Default directory:

```text
%USERPROFILE%\AppData\Local\VALOR_UpgradeAdvisor
```

Log filename format:

```text
UpgradeAdvisor_YYYY-MM-DD.log
```

Logs can record events such as:

* Application startup
* Administrator elevation
* Hardware-analysis activity
* Upgrade recommendation access
* Bottleneck analysis
* Report generation
* Errors
* Application activity

The application provides a menu option to display recent log entries.

---

# 🛡️ Administrator Privileges

The script checks whether it is running with Windows administrator privileges.

When administrator privileges are not detected, the script requests elevation through Windows UAC and restarts the application with administrator privileges.

This may be required for access to certain Windows system-management information.

> Users should review the script before execution and ensure that they understand its administrator-elevation behavior.

---

# 🖥️ Main Menu

The application provides the following menu:

```text
[1]  Analyze Current Hardware
[2]  CPU Upgrade Recommendations
[3]  RAM Upgrade Recommendations
[4]  Storage Upgrade Recommendations
[5]  GPU Upgrade Recommendations
[6]  Motherboard Compatibility Check
[7]  Detect Bottlenecks
[8]  Overall System Upgrade Plan
[9]  Generate Upgrade Report (TXT)
[10] Generate Upgrade Report (CSV)
[11] View Logs
[12] Exit
```

---

# 🚀 Installation & Usage

## Requirements

* Windows 10 or later
* Windows PowerShell
* Administrator privileges
* CIM/WMI access
* Standard Windows hardware-management interfaces

## Run the Script

Open PowerShell in the project directory:

```powershell
.\ComputerUpgrade.ps1
```

The script may request administrator permission through Windows UAC.

---

# 🔄 Typical Workflow

```text
              ┌─────────────────────┐
              │ Start Application   │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ Administrator Check │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ Hardware Detection  │
              └──────────┬──────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
        CPU             RAM          Motherboard
          │              │              │
          └──────────────┼──────────────┘
                         ▼
              ┌─────────────────────┐
              │ GPU & Storage Data  │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │ System Assessment   │
              └──────────┬──────────┘
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼
       Recommendations Bottlenecks Reports
                                       │
                              ┌────────┴────────┐
                              ▼                 ▼
                            TXT               CSV
```

---

# ⚠️ Important Limitations

This project is an **informational hardware analysis and upgrade advisory tool**.

It does not guarantee:

* Hardware compatibility
* System stability
* Benchmark performance
* Gaming FPS
* Specific application performance
* BIOS compatibility
* Power-supply adequacy
* Cooling adequacy
* Physical component clearance
* Actual upgrade cost
* Component availability

Always verify the exact specifications and compatibility of hardware with the component and motherboard manufacturer before making an upgrade.

---

# 💰 Recommendation and Pricing Disclaimer

The script contains predefined example hardware recommendations, estimated prices, and expected performance figures.

These values are included for **general reference and demonstration purposes**.

They should not be interpreted as:

* Live market prices
* Guaranteed purchase prices
* Guaranteed performance improvements
* Professional benchmark measurements

Hardware pricing and availability vary by:

* Country
* Retailer
* Time
* Product availability
* Hardware configuration

---

# 🔐 Privacy

The application collects local hardware information to perform its analysis.

Generated reports and logs may contain system-identifying information such as:

* Computer name
* Windows information
* Username
* Hardware configuration

Review generated reports and logs before publishing or sharing them.

Do not upload private system reports to a public GitHub repository without removing sensitive information.

---

# 🛠️ Technology

The project is implemented using:

```text
PowerShell
Windows CIM/WMI
Windows PowerShell
Windows UAC / Administrator Elevation
TXT Reporting
CSV Reporting
Local Logging
```

> 🔒 **Public GitHub access does not mean that this project is open source. The source code remains proprietary and is protected by the project's license.**

Please contact the copyright holder to discuss authorized source-code modification, development, integration, redistribution, commercial use, or licensing.

---

# 🚫 Proprietary Software Notice

**VALOR Computer Hardware Upgrade Advisor** is proprietary software developed by **VALOR**.

Copyright © 2026 VALOR. All Rights Reserved.

This project is **not open-source software**.

No permission is granted under:

* MIT License
* Apache License 2.0
* GNU GPL
* GNU LGPL
* BSD License
* Or any other open-source license

Unless expressly authorized in writing by the copyright holder, you may not:

* Copy the source code
* Modify the source code
* Create derivative works
* Redistribute the software
* Publish modified versions
* Repackage the software
* Sell the software
* Integrate the source code into another product
* Sublicense the software
* Remove or alter copyright notices
* Re-license the project
* Release modified versions under an open-source license
* Convert the project into an open-source project

All rights not expressly granted are reserved by the copyright holder.

See the `LICENSE` file for the complete legal terms.

---

## 📜 License
**Computer Security Latest Proprietary License**
**Copyright © 2026 VALOR. All Rights Reserved.**

This project is proprietary software and is not open source.

Use, copying, modification, redistribution, publication, sublicensing,
commercial use, and creation of derivative works are prohibited unless
explicitly authorized in writing by the copyright holder.

See the `LICENSE` file for the complete license terms.

---

# 👤 Project Information

**Project Name:** VALOR Computer Hardware Upgrade Advisor
**Version:** 3.0.0
**Developer:** VALOR
**Language:** PowerShell
**Platform:** Windows
**Copyright:** © 2026 VALOR

---

# 🔒 Copyright

Copyright © 2026 VALOR. All Rights Reserved.

**VALOR Computer Hardware Upgrade Advisor is proprietary software and is not open source.**
