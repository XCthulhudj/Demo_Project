# Demo_Project

---

A learning project integrating C, C++, and Python, designed to explore fundamental programming syntax, data structures, and algorithmic concepts.

![License](https://img.shields.io/badge/license-MIT-green)

## Environmental Dependencies

- **Operating System** – Windows 10/11.
- **Python** – Python programming and script execution.
- **CMake** – Build system configuration and project generation.
- **GCC/G++** – C and C++ compilers.
- **MinGW** – Provides the GNU toolchain and Make utility on Windows.

## Build Process

Run the following commands in PowerShell from the project root directory:

```powershell
mkdir bin
mkdir build
cd build
cmake -G "MinGW Makefiles" ..
mingw32-make.exe
```

## Configure GDB for Debugging

Before using the VS Code debugger, update the `miDebuggerPath` setting in `.vscode/launch.json` to match the location of `gdb.exe` on your system.

For example:

```json
"miDebuggerPath": "D:/App/mingw64/bin/gdb.exe"
```

**Note:** Replace the example path with the actual location of `gdb.exe` on your computer.

## Directory Structure

<div align="center">

| Path | Description |
| --- | --- |
| `.vscode/` | VS Code workspace settings, extensions, and development configurations. |
| `docs/` | Project documentation, technical notes, and learning materials. |
| `drivers/` | Hardware driver implementations and low-level interface code. |
| `lib/` | Third-party libraries and reusable software components. |
| `matlab/` | MATLAB scripts, mathematical models, and algorithm implementations. |
| `module/` | Independent functional modules and reusable code components. |
| `tools/` | Development utilities, helper scripts, and automation tools. |
| `bin/` | Compiled executables and binary files. |
| `build/` | CMake-generated build files and intermediate compilation artifacts. |

</div>

## Project Goals

- Practice fundamental C, C++, and Python syntax.
- Understand common data structures and algorithms.
- Explore mixed-language programming and integration.
- Learn CMake-based project configuration and compilation.
- Develop practical programming and debugging skills.

---

## Task List

- [x] Complete the README.md.