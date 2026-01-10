# VSCode Tasks for CMake Projects

This guide explains how to use the `tasks.json` file to automate CMake-based project workflows in VSCode.

## Overview

The `tasks.json` file contains predefined tasks for building, running, and testing CMake projects. These tasks streamline common development workflows by automating repetitive commands.

## Prerequisites

- VSCode with C/C++ extension installed
- CMake installed on your system
- Project dependencies (managed via `dependencies.sh`)
- Copy `tasks.json` to `.vscode/` folder in your project root directory

## Available Tasks

### Build Tasks

#### 1. **dependencies**
Downloads project dependencies using the dependencies script.
- **Command**: `./dependencies.sh`
- **Usage**: Run this first to fetch all required dependencies

#### 2. **configure**
Configures the CMake build system.
- **Command**: `cmake -S . -B build`
- **Depends on**: dependencies
- **Usage**: Sets up the build directory with default configuration

#### 3. **build**
Builds the entire project using all available CPU cores.
- **Command**: `cmake --build build --parallel $(nproc) --target all`
- **Depends on**: configure
- **Usage**: Compiles all targets in the project

#### 4. **clean**
Cleans build artifacts.
- **Command**: `cmake --build build --parallel $(nproc) --target clean`
- **Depends on**: configure-unit-tests
- **Usage**: Removes compiled binaries and object files

### Run Tasks

#### 5. **run**
Executes the built application with required environment variables.
- **Command**: `${workspaceFolder}/build/$(sed -n 's/^CMAKE_PROJECT_NAME:.*=//p' ${workspaceFolder}/build/CMakeCache.txt)`
- **Note**: This command extracts the project name from CMakeCache.txt. If this doesn't work, replace it with the absolute path to your project's target binary (e.g., `${workspaceFolder}/build/my-project-name`)
- **Depends on**: build
- **Environment Variables**:
  - `LICENSEKEY`: Your license key - **replace with your actual license**
- **Important**: Modify the environment variable value according to your requirements

### Testing Tasks

#### 6. **configure-unit-tests**
Configures CMake with unit tests enabled.
- **Command**: `cmake -S . -B build -Dtest=ON`
- **Depends on**: dependencies
- **Usage**: Prepares build system for testing

#### 7. **build-unit-tests**
Builds all unit test targets.
- **Depends on**: configure-unit-tests
- **Usage**: Compiles test binaries

#### 8. **run-unit-tests**
Executes all unit tests in the project.
- **Command**: `for target in $(cmake --build build --target help | grep tests | sed -n 's/.*\.\.\. //p'); do binary=$(sed -n "s|^.*/${target}\.dir$|&|p" build/CMakeFiles/TargetDirectories.txt | sed "s|/CMakeFiles/.*|/${target}|"); "$binary"; done`
- **Note**: This command finds and runs all test binaries. If this doesn't work, replace it with the absolute paths to your test binaries (e.g., `${workspaceFolder}/build/my-test-binary`)
- **Depends on**: build-unit-tests
- **Usage**: Runs all test binaries and reports results
- **Environment Variables**:
  - `LICENSEKEY`: Your license key - **replace with your actual license**
- **Important**: Modify the environment variable value according to your requirements

### Sanitizer Builds

#### Address Sanitizer (ASAN)
- **configure-asan**: Configures build with AddressSanitizer
- **Command**: `cmake -S . -B build-asan -Dtest=ON -D__SANITIZE_ADDRESS__=ON`
- **build-asan**: Builds with ASAN enabled
- **Usage**: Detects memory errors (buffer overflows, use-after-free, etc.)

#### Undefined Behavior Sanitizer (UBSAN)
- **configure-ubsan**: Configures build with UndefinedBehaviorSanitizer
- **Command**: `cmake -S . -B build-ubsan -Dtest=ON -D__SANITIZE_UNDEFINED__=ON`
- **build-ubsan**: Builds with UBSAN enabled
- **Usage**: Detects undefined behavior at runtime

#### Thread Sanitizer (TSAN)
- **configure-tsan**: Configures build with ThreadSanitizer
- **Command**: `cmake -S . -B build-tsan -Dtest=ON -D__SANITIZE_THREAD__=ON`
- **build-tsan**: Builds with TSAN enabled
- **Usage**: Detects data races and threading issues

## How to Run Tasks

### Method 1: Command Palette
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS)
2. Type "Tasks: Run Task"
3. Select the desired task from the list

### Method 2: Terminal Menu
1. Go to **Terminal** → **Run Task**
2. Select the task you want to execute

### Method 3: Keyboard Shortcut
1. Press `Ctrl+Shift+B` (default build shortcut)
2. Select a build task from the list

### Method 4: Tasks Panel
1. Open the Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Configure Default Build Task"
3. Select a task to set as default
4. Press `Ctrl+Shift+B` to run it directly

## Common Workflows

### First-Time Setup
```
1. Run "dependencies" → Downloads required libraries
2. Run "configure" → Sets up CMake build system
3. Run "build" → Compiles the project
4. Run "run" → Executes the application
```

### Development Cycle
```
1. Make code changes
2. Run "build" → Incrementally compiles changes
3. Run "run" → Tests your changes
```

### Testing Workflow
```
1. Run "configure-unit-tests" → Enable test builds
2. Run "build-unit-tests" → Compile tests
3. Run "run-unit-tests" → Execute all tests
```

### Debugging Memory Issues
```
1. Run "configure-asan" → Enable AddressSanitizer
2. Run "build-asan" → Build with ASAN
3. Execute binary from "build-asan" directory
```

## Customization

### Modifying Tasks for Your Project

To adapt the tasks for your specific project, edit the `tasks.json` file in your project's `.vscode/` directory:

1. **Change dependency parameters**:
   ```json
   "args": []
   ```
   The dependencies task currently has no arguments. Modify if your `dependencies.sh` script requires parameters.

2. **Adjust environment variables**:
   Update the `env` section in "run" and "run-unit-tests" tasks with your license key:
   ```json
   "env": {
       "LICENSEKEY": "your-actual-license-key"
   }
   ```

3. **Modify build options**:
   Add CMake flags in the "configure" task:
   ```json
   "args": ["-S", ".", "-B", "build", "-DYOUR_OPTION=ON"]
   ```

### Adding Tasks to Your Project

To use these tasks in your own CMake project:

1. Copy `tasks.json` to your project's `.vscode/` directory:
   ```bash
   mkdir -p .vscode
   cp /home/asad/Workspace/asali23/scripts/vscode/tasks.json .vscode/
   ```

2. Update the paths and parameters to match your project structure

3. Ensure `dependencies.sh` is accessible or modify the "dependencies" task

## Troubleshooting

### Task Dependency Errors
If a task fails, check that its dependencies have been run successfully. Tasks with `dependsOn` will automatically run prerequisite tasks.

### Missing CMake Cache
If "clean" or "run" tasks fail, ensure "configure" has been run at least once to generate `CMakeCache.txt`.

### Environment Variables Not Set
If the application fails to run, verify that the `LICENSEKEY` environment variable in the "run" task is set to your actual license key.

### Sanitizer Build Issues
For sanitizer builds (ASAN, UBSAN, TSAN), ensure your compiler supports the respective sanitizers and that the build directories (build-asan, etc.) are clean before building.

## Additional Resources

- [VSCode Tasks Documentation](https://code.visualstudio.com/docs/editor/tasks)
- [CMake Documentation](https://cmake.org/documentation/)
- Company-specific build documentation in project repositories

## Notes

- All tasks use `${workspaceFolder}` variable, which automatically resolves to your project root
- Tasks with `problemMatcher: ["$gcc"]` will parse compiler output and display errors in the Problems panel
- Background tasks can be created by adding `"isBackground": true` to task definitions
- Sanitizer builds use separate build directories (build-asan, build-ubsan, build-tsan) to avoid conflicts with regular builds
