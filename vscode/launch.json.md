# VSCode C++ Launch Configurations

This guide explains how to use and adapt the provided `launch.json` for debugging C++ (CMake-built) targets, sanitizer builds, and unit tests.

## Overview
The `launch.json` defines multiple debug configurations using the `cppdbg` adapter (GDB). Each configuration corresponds to a build variant or test target produced by the tasks in `tasks.json`.

## Prerequisites
- GCC / GDB installed (path matches `miDebuggerPath` in the file)
- Matching build directories (`build`, `build_asan`, `build_tsan`, `build_ubsan`, etc.) created by running the corresponding tasks
- A valid `<license key>` replacing the placeholder where required
- Unit test targets generated (e.g., `my_app_tests`)

## File Placement
Copy `launch.json` into your project's `.vscode/` directory:
```bash
mkdir -p .vscode
cp /home/asad/Workspace/asali23/scripts/vscode/launch.json .vscode/
```

## Common Fields
- `name`: Display name shown in the debug configuration picker.
- `type`: Always `cppdbg` here (C/C++ debugging with GDB).
- `request`: `launch` starts the program.
- `program`: Absolute or workspace-relative path to the binary to debug.
- `args`: Command-line arguments passed to the binary.
- `cwd`: Working directory (usually `${workspaceFolder}`).
- `environment`: Array of environment variable objects (`name`/`value`). Replace placeholders.
- `MIMode`: Debugger protocol; `gdb` for GNU debugger.
- `miDebuggerPath`: Actual path to `gdb` inside toolchain (adjust for your system).
- `setupCommands`: GDB commands run before starting (pretty-printing, disassembly flavor). Safe to keep.
- `externalConsole`: `false` keeps output in VSCode debug console.
- `stopAtEntry`: `true` halts at program entry (useful for initial breakpoint setup or inspecting early initialization). Set `false` for faster start; you can remove this line entirely if you never need to pause at entry.
- `preLaunchTask`: Ensures the matching build task runs first (must exist in `tasks.json`). Remove this line if you do not want to rebuild before every debug run.

## Configuration Matrix
| Config Name | Binary Path | PreLaunch Task | Purpose |
|-------------|-------------|----------------|---------|
| Debug | `build/my_app` | `build` | Standard build debug session |
| Debug (ASan) | `build_asan/my_app` | `build_asan` | AddressSanitizer memory error detection |
| Debug (TSan) | `build_tsan/my_app` | `build_tsan` | ThreadSanitizer race detection |
| Debug Unit Tests | `build/unit_tests/my_app_tests` | `build_unit_tests` | Run / debug test suite (regular build) |
| Debug (UBSan) | `build_ubsan/my_app` | `build_ubsan` | UndefinedBehaviorSanitizer runtime UB checks |
| Debug Unit Tests (ASan) | `build_asan/unit_tests/my_app_tests` | `build_asan` | Test suite with ASan |
| Debug Unit Tests (TSan) | `build_tsan/unit_tests/my_app_tests` | `build_tsan` | Test suite with TSan |
| Debug Unit Tests (UBSan) | `build_ubsan/unit_tests/my_app_tests` | `build_ubsan` | Test suite with UBSan |

## Environment Variables
Replace these placeholders / values as needed:
- `LICENSEKEY`: Set to your actual shared memory license key.
- Sanitizer-specific vars:
  - `ASAN_OPTIONS`: e.g. `detect_leaks=1` (add more like `abort_on_error=1` if desired)
  - `TSAN_OPTIONS`: e.g. `history_size=7` (adjust for deeper race traces)

## Customization Steps
1. Adjust every `program` path if your target binary name differs.
2. Remove configurations you do not use to reduce clutter.
3. Change `miDebuggerPath` to `gdb` path on your system (e.g., `/usr/bin/gdb`).
4. Toggle `stopAtEntry` to `false` after initial debugging.
5. Add `"symbolSearchPath"` or `"visualizerFile"` if using custom NatVis / pretty printers.
6. For unit test configurations, the `args` are set to specify the test directory (e.g., `["--test-dir", "${workspaceFolder}/build"]`). Adjust if your test framework uses different flags.
7. If using LLDB (macOS), change `type` to `cppdbg`, `MIMode` to `lldb` and update paths accordingly.

## Extending Configurations
Add a new configuration for a specific component:
```json
{
    "name": "Debug (Component X)",
    "type": "cppdbg",
    "request": "launch",
    "program": "${workspaceFolder}/build/component_x/bin/x_server",
    "cwd": "${workspaceFolder}",
    "environment": [
        {"name": "LICENSEKEY", "value": "<license key>"}
    ],
    "MIMode": "gdb",
    "miDebuggerPath": "/usr/bin/gdb",
    "externalConsole": false,
    "stopAtEntry": false,
    "preLaunchTask": "build"
}
```

## How to Run
1. Open the Debug view (`Ctrl+Shift+D`).
2. Select a configuration from the dropdown.
3. Press `F5` to start debugging.
4. Adjust breakpoints, inspect variables, use CALL STACK panel.

## Additional Resources
- VSCode C++ Debugging: https://code.visualstudio.com/docs/cpp/cpp-debug
- Launch Configuration Reference: https://code.visualstudio.com/docs/editor/debugging#_launch-configurations
- GDB Manual: https://sourceware.org/gdb/current/onlinedocs/gdb/
- CMake Debugging Tips: https://cmake.org/cmake/help/latest/manual/cmake.1.html#debugging
