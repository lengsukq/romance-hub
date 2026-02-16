# Android Release 签名配置

为保障 **GitHub Actions 每次打包的 APK 签名一致**（便于覆盖安装、应用商店更新），需使用固定 keystore，并在仓库 Secrets 中配置。

## 为什么之前每次签名不一致？

- Release 构建曾使用 `signingConfigs.debug`。
- CI 每次跑在全新 runner 上，没有持久化 keystore，Gradle 会生成或使用不同的 debug 密钥，导致**每次签名不同**。

## 1. 本地生成 release keystore（仅需一次）

在本地执行（需已安装 JDK）：

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

按提示输入：

- keystore 密码（记作 **storePassword**）
- 密钥密码（可与 keystore 密码相同，记作 **keyPassword**）
- key alias 使用上面的 `upload`（记作 **keyAlias**）
- 其余姓名、组织等可随意填写

生成后得到 `upload-keystore.jks`，**妥善备份并勿提交到 Git**。

## 2. 在 GitHub 仓库配置 Secrets

仓库 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**，新增：

| Secret 名称 | 说明 |
|-------------|------|
| `ANDROID_KEYSTORE_BASE64` | 将 `upload-keystore.jks` 做 Base64 编码后的内容。PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))`；Linux/macOS: `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | 上面的 **storePassword** |
| `ANDROID_KEY_PASSWORD` | 上面的 **keyPassword** |
| `ANDROID_KEY_ALIAS` | 上面的 **keyAlias**（如 `upload`） |

配置完成后，每次 workflow 构建 Android Release 时会用同一套 keystore 签名，**签名将保持一致**。

## 3. 本地 Release 构建（可选）

若希望在本地也用同一套 release 签名：

1. 将 `upload-keystore.jks` 放到 `flutter_app/android/app/` 下（或任意位置，路径在 key.properties 中写对即可）。
2. 在 `flutter_app/android/key.properties` 中写入（**勿提交此文件**）：

```properties
storePassword=你的store密码
keyPassword=你的key密码
keyAlias=upload
storeFile=app/upload-keystore.jks
```

`storeFile` 为相对于 `flutter_app/android/` 的路径。保存后执行 `flutter build apk --release` 即使用该 keystore。

## 4. 未配置 Secrets 时

若未配置上述 Secrets，workflow 会跳过「配置 Android Release 签名」步骤，Release 仍使用 debug 签名，**每次 CI 签名仍可能不一致**。仅用于临时测试，正式发布请务必配置 Secrets。
