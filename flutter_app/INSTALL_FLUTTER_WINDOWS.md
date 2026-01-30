# Windows 安装 Flutter 指南

## 📥 安装步骤

### 1. 下载 Flutter SDK

1. 访问 [Flutter 官网](https://flutter.dev/docs/get-started/install/windows)
2. 下载最新的 Flutter SDK（稳定版）
3. 解压到合适的位置，例如：`C:\src\flutter`
   - ⚠️ **重要**：不要解压到需要管理员权限的目录（如 `C:\Program Files\`）

### 2. 配置环境变量

#### 方法一：通过系统设置（推荐）

1. 右键"此电脑" → "属性"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"系统变量"中找到 `Path`，点击"编辑"
5. 点击"新建"，添加 Flutter 的 `bin` 目录路径：
   ```
   C:\src\flutter\bin
   ```
6. 点击"确定"保存所有更改

#### 方法二：通过 PowerShell（临时）

```powershell
# 临时添加到当前会话
$env:Path += ";C:\src\flutter\bin"
```

### 3. 验证安装

打开新的 PowerShell 或命令提示符窗口，运行：

```powershell
flutter --version
```

如果显示版本信息，说明安装成功！

### 4. 运行 Flutter Doctor

```powershell
flutter doctor
```

这会检查你的开发环境，显示需要安装的组件。

### 5. 安装必要的工具

根据 `flutter doctor` 的提示安装：

#### Android 开发（可选，用于 Android 应用）

1. 安装 [Android Studio](https://developer.android.com/studio)
2. 在 Android Studio 中安装 Android SDK
   - 打开 Android Studio
   - 进入 `File` → `Settings` → `Appearance & Behavior` → `System Settings` → `Android SDK`
   - 在 `SDK Tools` 标签页中，确保勾选：
     - ✅ Android SDK Build-Tools
     - ✅ Android SDK Command-line Tools (latest)
     - ✅ Android SDK Platform-Tools
     - ✅ Android Emulator
   - 点击 `Apply` 安装选中的组件
3. 配置环境变量（如果未自动配置）：
   - 创建系统变量 `ANDROID_HOME`，值为 Android SDK 路径（通常是 `C:\Users\<用户名>\AppData\Local\Android\Sdk`）
   - 在 `Path` 环境变量中添加：
     - `%ANDROID_HOME%\platform-tools`
     - `%ANDROID_HOME%\tools`
     - `%ANDROID_HOME%\cmdline-tools\latest\bin`
4. 接受 Android 许可证：
   ```powershell
   flutter doctor --android-licenses
   # 全部输入 y 接受所有许可证
   ```
5. 配置 Android 模拟器或连接真机

#### Visual Studio（可选，用于 Windows 桌面应用）

1. 安装 [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) 或 Visual Studio Build Tools
2. 在安装程序中选择"使用 C++ 的桌面开发"工作负载
3. **重要**：在右侧的"安装详细信息"中，确保勾选以下组件：
   - ✅ **MSVC v142 - VS 2019 C++ x64/x86 生成工具**（或最新版本）
   - ✅ **C++ CMake 工具（适用于 Windows）**
   - ✅ **Windows 10 SDK**（选择最新版本，如 10.0.19041.0 或更高）
   - ✅ **Windows 11 SDK**（如果可用，也建议安装）
4. 点击"安装"并等待完成
5. 安装完成后，重启 PowerShell 并再次运行 `flutter doctor` 验证

#### Chrome（可选，用于 Web 应用）

- 安装 [Google Chrome](https://www.google.com/chrome/)

### 6. 接受 Android 许可证（如果使用 Android）

```powershell
flutter doctor --android-licenses
```

## ✅ 验证安装

运行以下命令验证所有组件：

```powershell
flutter doctor -v
```

应该看到类似以下输出：

```
[✓] Flutter (Channel stable, 3.x.x, ...)
[✓] Windows Version (Installed version of Windows is version 10 or higher)
[✓] Android toolchain (Android SDK version ...)
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows
[✓] Android Studio
[✓] VS Code
[✓] Connected device
[✓] Network resources
```

## 🚀 快速测试

安装完成后，测试 Flutter 是否正常工作：

```powershell
# 创建测试项目
flutter create test_app
cd test_app

# 运行在 Chrome
flutter run -d chrome
```

## 📝 常见问题

### 问题 1: `flutter: 无法识别`

**解决方案**：
- 确保已添加到 PATH 环境变量
- 重启 PowerShell/命令提示符
- 检查 Flutter 安装路径是否正确

### 问题 2: PowerShell 执行策略错误

**解决方案**：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 问题 3: Android 许可证未接受

**解决方案**：
```powershell
flutter doctor --android-licenses
# 全部输入 y 接受
```

### 问题 4: Android cmdline-tools 组件缺失

**解决方案**：
1. 打开 Android Studio
2. 进入 `File` → `Settings` → `Appearance & Behavior` → `System Settings` → `Android SDK`
3. 切换到 `SDK Tools` 标签页
4. 勾选 `Android SDK Command-line Tools (latest)`
5. 点击 `Apply` 安装
6. 如果仍然报错，手动下载并安装：
   - 访问 [Android Command Line Tools](https://developer.android.com/studio#command-line-tools-only)
   - 下载 Windows 版本
   - 解压到 `%ANDROID_HOME%\cmdline-tools\latest\`
   - 确保环境变量 `Path` 中包含 `%ANDROID_HOME%\cmdline-tools\latest\bin`

### 问题 5: Visual Studio 缺少必要组件

**解决方案**：
1. 打开 Visual Studio Installer
2. 点击"修改"按钮
3. 确保选择了"使用 C++ 的桌面开发"工作负载
4. 在右侧的"安装详细信息"中，检查并勾选：
   - MSVC v142 - VS 2019 C++ x64/x86 生成工具（或最新版本）
   - C++ CMake 工具（适用于 Windows）
   - Windows 10 SDK（最新版本）
5. 点击"修改"完成安装
6. 重启 PowerShell 后运行 `flutter doctor` 验证

### 问题 6: 网络问题（下载依赖失败）

**解决方案**：
- 使用国内镜像（在 PowerShell 中设置）：
```powershell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

## 🔗 有用的链接

- [Flutter 官方文档](https://flutter.dev/docs)
- [Flutter 中文网](https://flutter.cn/)
- [Dart 语言教程](https://dart.dev/guides)

## 📦 安装完成后

安装完成后，回到项目目录：

```powershell
cd flutter_app
flutter pub get
flutter run -d chrome
```

享受 Flutter 开发吧！🎉
