# VSCode Tasks for CMake Projects

Build, run, and test tasks for CMake-based C++ projects.

## What this provides

Pre-configured `tasks.json` for:
- Dependency installation (`dependencies`)
- CMake configuration (`configure`)
- Building (`build`)
- Running applications (`run`)
- Unit testing (`configure-unit-tests`, `build-unit-tests`, `run-unit-tests`)
- Sanitizer builds (ASan, TSan, UBSan)

## Quick Start

1. Copy to your project:
   ```bash
   mkdir -p .vscode
   cp tasks.json .vscode/
   ```

2. Update placeholders:
   - Replace `<license key>` with actual license
   - Adjust `program` paths if binary names differ

3. Run tasks: `Ctrl+Shift+P` → "Tasks: Run Task"

## Available Tasks

### Build Tasks
| Task | Command | Depends On |
|------|---------|------------|
| `dependencies` | `./dependencies.sh` | - |
| `configure` | `cmake -S . -B build` | dependencies |
| `build` | `cmake --build build --parallel $(nproc)` | configure |
| `clean` | `cmake --build build --target clean` | configure |

### Run Tasks
| Task | Purpose | Environment |
|------|---------|-------------|
| `run` | Execute built application | `LICENSEKEY` |

### Test Tasks
| Task | Command | Depends On |
|------|---------|------------|
| `configure-unit-tests` | `cmake -S . -B build -Dtest=ON` | dependencies |
| `build-unit-tests` | `cmake --build build --target all` | configure-unit-tests |
| `run-unit-tests` | Run all test binaries | `LICENSEKEY` |

### Sanitizer Builds
| Task | Purpose |
|------|---------|
| `configure-asan` / `build-asan` | AddressSanitizer (memory errors) |
| `configure-tsan` / `build-tsan` | ThreadSanitizer (data races) |
| `configure-ubsan` / `build-ubsan` | UndefinedBehaviorSanitizer |

## Common Workflows

**First-time setup:**
```
dependencies → configure → build → run
```

**Development cycle:**
```
build → run
```

**Testing:**
```
configure-unit-tests → build-unit-tests → run-unit-tests
```

## Customization

Update `tasks.json` in your project's `.vscode/` directory:

1. **Change binary path** (run task):
   ```json
   "command": "${workspaceFolder}/build/your-binary-name"
   ```

2. **Set environment variable**:
   ```json
   "env": { "LICENSEKEY": "your-actual-key" }
   ```

3. **Add CMake options**:
   ```json
   "args": ["-S", ".", "-B", "build", "-DYOUR_OPTION=ON"]
   ```

## Running Tasks

- **Command Palette**: `Ctrl+Shift+P` → "Tasks: Run Task"
- **Keyboard**: `Ctrl+Shift+B` (default build)
- **Terminal Menu**: Terminal → Run Task

## References

- [VSCode Tasks Documentation](https://code.visualstudio.com/docs/editor/tasks)
- [CMake Documentation](https://cmake.org/documentation/)
