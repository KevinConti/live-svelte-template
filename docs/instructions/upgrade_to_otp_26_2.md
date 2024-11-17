# Upgrading to Erlang/OTP 26.2 on Windows for an Elixir Project

Upgrading to Erlang/OTP 26.2 is essential for leveraging the latest features and improvements in your Elixir projects. This guide provides a comprehensive, step-by-step process tailored for Windows users to upgrade to OTP 26.2 for an Elixir project.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Verify Current Erlang/OTP and Elixir Versions](#step-1-verify-current-erlangotp-and-elixir-versions)
3. [Step 2: Download Erlang/OTP 26.2 for Windows](#step-2-download-erlangotp-262-for-windows)
4. [Step 3: Install Erlang/OTP 26.2](#step-3-install-erlangotp-262)
5. [Step 4: Update Environment Variables](#step-4-update-environment-variables)
6. [Step 5: Verify Erlang/OTP 26.2 Installation](#step-5-verify-erlangotp-262-installation)
7. [Step 6: Update Elixir Dependencies](#step-6-update-elixir-dependencies)
8. [Step 7: Test Your Elixir Project](#step-7-test-your-elixir-project)
9. [Step 8: Update Elixir (Optional)](#step-8-update-elixir-optional)
10. [Troubleshooting Tips](#troubleshooting-tips)
11. [Conclusion](#conclusion)

## Prerequisites

Before proceeding, ensure you have the following:

1. **Administrative Access**: You may need admin rights to install software and modify environment variables.
2. **Elixir Installed**: Ensure Elixir is already installed on your system.
3. **Backup Your Project**: It's good practice to backup your project or use version control (e.g., Git) before making significant changes.

## Step 1: Verify Current Erlang/OTP and Elixir Versions

Before upgrading, check the current versions of Erlang/OTP and Elixir to understand your starting point.

1. **Open Command Prompt**:
   - Press `Win + R`, type `cmd`, and press `Enter`.

2. **Check Erlang/OTP Version**:
   ```shell
   erl -version
   ```
   - Alternatively, start the Erlang shell:
     ```shell
     erl
     ```
     Then, within the shell, type:
     ```erlang
     erlang:system_info(otp_release).
     ```
     Press `Ctrl + C` twice to exit.

3. **Check Elixir Version**:
   ```shell
   elixir --version
   ```

## Step 2: Download Erlang/OTP 26.2 for Windows

1. **Visit the Official Erlang/OTP Downloads Page**:
   - Navigate to [Erlang Downloads](https://www.erlang.org/downloads).

2. **Select OTP 26.2**:
   - Find and select the Erlang/OTP 26.2 version suitable for Windows. Look for a file named similar to `OTP-26.2-Win64.exe`.

3. **Download the Installer**:
   - Click the link to download the Windows installer (`.exe` file).

## Step 3: Install Erlang/OTP 26.2

1. **Run the Installer**:
   - Locate the downloaded `OTP-26.2-Win64.exe` file and double-click to run it.

2. **Follow Installation Prompts**:
   - **Welcome Screen**: Click `Next`.
   - **License Agreement**: Read and accept the terms, then click `Next`.
   - **Destination Folder**: Choose the installation directory (default is usually fine) and click `Next`.
   - **Select Components**: Ensure all necessary components are selected. Typically, the defaults are sufficient.
   - **Install**: Click `Install` to begin the installation process.
   - **Completion**: Once installation is complete, click `Finish`.

## Step 4: Update Environment Variables

Ensure that the new Erlang/OTP installation is recognized system-wide.

1. **Open Environment Variables**:
   - Right-click `This PC` or `My Computer` on the desktop or in File Explorer.
   - Select `Properties` > `Advanced system settings` > `Environment Variables`.

2. **Update `ERLANG_HOME` (if set)**:
   - In the `System variables` section, look for `ERLANG_HOME`.
   - If it exists, update its value to the new installation path, e.g., `C:\Program Files\erl-26.2`.

3. **Update `Path` Variable**:
   - In `System variables`, find and select `Path`, then click `Edit`.
   - Ensure the path to Erlang's `bin` directory is present, e.g., `C:\Program Files\erl-26.2\bin`.
   - If an older Erlang path exists, update it to the new version or remove it to prevent conflicts.
   - Click `OK` to save changes.

4. **Apply Changes**:
   - Close and reopen any open Command Prompt or terminal windows to apply the updated environment variables.

## Step 5: Verify Erlang/OTP 26.2 Installation

1. **Open Command Prompt**:
   - Press `Win + R`, type `cmd`, and press `Enter`.

2. **Check Erlang Version**:
   ```shell
   erl -version
   ```
   - Expected output should indicate OTP 26.2.

3. **Alternative Verification**:
   - Start the Erlang shell:
     ```shell
     erl
     ```
   - Within the shell, type:
     ```erlang
     erlang:system_info(otp_release).
     ```
     - Should return `"26.2"`.
   - Exit the shell with `Ctrl + C` twice.

## Step 6: Update Elixir Dependencies

After upgrading Erlang/OTP, you should update and recompile your Elixir project's dependencies to ensure compatibility.

1. **Navigate to Your Elixir Project**:
   - In Command Prompt:
     ```shell
     cd path\to\your\elixir_project
     ```

2. **Update Dependencies**:
   ```shell
   mix deps.update --all
   ```

3. **Clean and Recompile**:
   - Clean previous build artifacts:
     ```shell
     mix clean
     ```
   - Recompile the project:
     ```shell
     mix compile
     ```

4. **Handle Potential Issues**:
   - If any dependencies are not compatible with OTP 26.2, consider updating them individually or checking for updates from their maintainers.

## Step 7: Test Your Elixir Project

Ensure that your project runs correctly with the new Erlang/OTP version.

1. **Run Tests**:
   ```shell
   mix test
   ```
   - Ensure all tests pass. Address any failures that may arise due to the upgrade.

2. **Start the Application**:
   ```shell
   mix run --no-halt
   ```
   - Verify that the application starts without issues.

3. **Check Logs and Functionality**:
   - Monitor application logs and test key functionalities to ensure everything operates as expected.

## Step 8: Update Elixir (Optional)

While not mandatory, it's good practice to ensure you're using a compatible and possibly updated Elixir version with the new Erlang/OTP.

1. **Check Current Elixir Version**:
   ```shell
   elixir --version
   ```

2. **Download the Latest Elixir Installer**:
   - Visit [Elixir Downloads](https://elixir-lang.org/install.html#windows) and download the latest Windows installer if an update is available.

3. **Run the Elixir Installer**:
   - Follow similar steps as the Erlang installer to update Elixir.

4. **Verify Elixir Version**:
   ```shell
   elixir --version
   ```

## Troubleshooting Tips

- **Conflicting Erlang Versions**: Ensure only one Erlang version is in your `Path` to prevent conflicts.
- **Permission Issues**: Run installers and Command Prompt as an administrator if you encounter permission errors.
- **Dependency Compatibility**: Some dependencies may not yet support OTP 26.2. Check their documentation or repositories for updates.
- **Environment Variable Changes**: If changes to environment variables aren't recognized, restart your computer to ensure they take effect.

## Conclusion

Upgrading to Erlang/OTP 26.2 on Windows for your Elixir project involves downloading and installing the new Erlang version, updating environment variables, updating and recompiling your project's dependencies, and thoroughly testing your application. Following this guide ensures a smooth transition, allowing you to take advantage of the latest features and improvements in Erlang/OTP and Elixir.

If you encounter any issues during the upgrade process, refer to the official [Erlang](https://www.erlang.org/doc/) and [Elixir](https://elixir-lang.org/docs.html) documentation or seek assistance from the community forums.