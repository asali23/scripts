# VSCode C++ Launch Configurations

Debug configurations for CMake-built C++ targets with sanitizer support.

## What this provides

Pre-configured `launch.json` for debugging:
- Standard debug builds
- AddressSanitizer (ASan), ThreadSanitizer (TSan), UndefinedBehaviorSanitizer (UBSan) builds
- Unit tests with and without sanitizers

## Quick Start

1. Copy to your project:
   ```bash
   mkdir -p .vscode
   cp launch.json .vscode/
   ```

2. Update paths:
   - Adjust `program` paths to match your binary locations
   - Update `miDebuggerPath` to your GDB path
   - Replace `<license key>` in environment variables

3. Start debugging: `Ctrl+Shift+D` → Select configuration → `F5`

## Configuration Matrix

| Config Name | Binary Path | PreLaunch Task | Purpose |
|-------------|-------------|----------------|---------|
| Debug | `build/my_app` | `build` | Standard debug session |
| Debug (ASan) | `build_asan/my_app` | `build_asan` | Memory error detection |
| Debug (TSan) | `build_tsan/my_app` | `build_tsan` | Race detection |
| Debug (UBSan) | `build_ubsan/my_app` | `build_ubsan` | Undefined behavior checks |
| Debug Unit Tests | `build/unit_tests/my_app_tests` | `build_unit_tests` | Run/debug test suite |

## Key Fields

- `program`: Path to the binary to debug
- `args`: Command-line arguments
- `environment`: Environment variables (e.g., `LICENSEKEY`)
- `miDebuggerPath`: Path to GDB
- `preLaunchTask`: Build task to run before debugging
- `stopAtEntry`: Pause at entry point (`true`/`false`)

## Customization

Add a new configuration:
```json
{
    "name": "Debug (Component X)",
    "type": "cppdbg",
    "request": "launch",
    "program": "${workspaceFolder}/build/component_x/bin/x_server",
    "cwd": "${workspaceFolder}",
    "MIMode": "gdb",
    "miDebuggerPath": "/usr/bin/gdb"
}
```

## References

- [VSCode C++ Debugging](https://code.visualstudio.com/docs/cpp/cpp-debug)
- [GDB Manual](https://sourceware.org/gdb/current/onlinedocs/gdb/)
