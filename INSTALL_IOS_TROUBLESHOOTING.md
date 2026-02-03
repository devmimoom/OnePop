# iOS 安裝到真機排錯

## App 沒有留在手機（安裝後消失）

若用 `flutter run` 安裝後 app 沒有留在手機上，請改用 **Xcode 建置並安裝**，通常就能常駐：

1. **用 Xcode 開啟專案**
   ```bash
   open ios/Runner.xcworkspace
   ```
2. 上方 **Run destination** 選你的 iPhone（例如：xxx 的 iPhone）。
3. 選單 **Product** → **Run**（或按 ⌘R），等建置完成。
4. 安裝完成後，app 會留在手機主畫面。若出現「未受信任的開發者」，請到手機 **設定** → **一般** → **VPN 與裝置管理** → 信任你的開發者帳號。

**補充**：用免費 Apple ID 簽署的 app 約 7 天後會過期，需重新用 Xcode 跑一次安裝。

---

## 若出現「無法驗證其完整性」或 Could not run ... on device

錯誤可能類似：
- `無法安裝此App，因為無法驗證其完整性`
- `Failed to verify code signature of ... objective_c.framework (The executable contains an invalid signature.)`
- `Could not run build/ios/iphoneos/Runner.app on [裝置]. Try launching Xcode...`

**建議做法：用 Xcode 建置並安裝**

1. **用 Xcode 開啟專案**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **選擇你的 iPhone**
   - 上方工具列「Run destination」選你的實機（例如：Josh 的 iPhone），不要選模擬器。

3. **簽章設定**
   - 左側點選 **Runner** 專案 → 選 **Runner** target → 分頁 **Signing & Capabilities**
   - 勾選 **Automatically manage signing**
   - **Team** 選你的 Apple ID 開發者帳號（若沒有可先選「Add an Account」登入）

4. **建置並安裝**
   - 選單 **Product** → **Run**（或按 ⌘R）
   - 等待建置完成，app 會安裝到手機並啟動。

5. **若手機出現「未受信任的開發者」**
   - 手機：**設定** → **一般** → **VPN 與裝置管理**（或「描述檔與裝置管理」）
   - 點你的開發者帳號 → **信任「xxx」**

**若仍出現「objective_c.framework invalid signature」或「無法驗證其完整性」**

- 專案已加入 **Sign Frameworks** Run Script（Runner target → Build Phases），會在嵌入 Pods 後重新簽署 `Runner.app/Frameworks` 內所有 `.framework` 與 `.dylib`，多數情況可解決此錯誤。
- 若仍失敗，請依序嘗試：
  1. **Xcode**：選單 **Product** → **Clean Build Folder**（⇧⌘K），再 **Product** → **Run**。
  2. **指令列**：`flutter clean`，然後 `cd ios && pod install`，再從 Xcode 執行 Run。
  3. 確認 **Signing & Capabilities** 的 Team 與 Provisioning Profile 正確，且裝置已加入該 Profile（若為付費開發者帳號）。

---

## 若 Clean 失敗（flutter clean 或 Xcode Clean Build Folder）

若 **flutter clean** 或 **Xcode → Product → Clean Build Folder** 失敗兩次，請改用手動刪除再還原：

### 做法一：flutter clean 失敗時

1. **先關閉 Xcode**（避免鎖住 build 目錄）。
2. 在專案根目錄執行（終端機）：
   ```bash
   cd /Users/Ariel/開發中APP/LearningBubbles
   rm -rf build
   rm -rf ios/build
   rm -rf ios/Pods
   rm -rf ios/.symlinks
   rm -rf ios/Podfile.lock
   ```
3. 還原依賴與 iOS 設定：
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```
4. 再用 Xcode 開啟 `ios/Runner.xcworkspace`，選 **Product** → **Run**（不必先按 Clean）。

### 做法二：Xcode Clean Build Folder 失敗時（「Could not delete ... because it was not created by the build system」）

若 Xcode 顯示：**Could not delete `.../build/ios/iphoneos` because it was not created by the build system and it is not a subfolder of derived data**，代表該目錄是 Flutter 建的，Xcode 預設不刪。可二擇一：

**A. 依 Xcode 建議，標記為可刪後再 Clean**

在終端機執行（路徑請改成你的專案根目錄）：

```bash
# 標記 build/ios/iphoneos 為建置系統可刪
xattr -w com.apple.xcode.CreatedByBuildSystem true "/Users/Ariel/開發中APP/LearningBubbles/build/ios/iphoneos"
```

若 `build/ios` 底下還有其他目錄（例如 `iphonesimulator`）導致 Clean 失敗，可一併標記：

```bash
cd /Users/Ariel/開發中APP/LearningBubbles/build/ios
for d in */; do xattr -w com.apple.xcode.CreatedByBuildSystem true "$d"; done
```

之後在 Xcode 再試一次 **Product** → **Clean Build Folder**（⇧⌘K），再 **Run**。

**B. 不依賴 Clean，改用手動刪除**

1. **完全關閉 Xcode**（⌘Q）。
2. 手動刪除專案建置產物：
   ```bash
   cd /Users/Ariel/開發中APP/LearningBubbles
   rm -rf build
   rm -rf ios/build
   ```
3. 重新開啟 `ios/Runner.xcworkspace`，直接 **Product** → **Run**（不必再按 Clean）。

若刪除時出現「Operation not permitted」或檔案被佔用，請確認已關閉 Xcode、模擬器與連接的 iPhone，再試一次；必要時重開機後再執行上述刪除。

**若 Clean 成功後仍出現「Framework 'Pods_Runner' not」或 Linker command failed**

- 代表 CocoaPods 與 Xcode 不同步。請在終端機執行：
  ```bash
  cd /Users/Ariel/開發中APP/LearningBubbles/ios
  pod install
  ```
  再從 Xcode **Product** → **Run**（或先 Clean 再 Run）。

---

## 指令列安裝（在 Xcode 跑過一次成功後可再試）

```bash
# 清理後再試
flutter clean
flutter run --release -d <你的 iPhone 裝置 ID>
# 裝置 ID 可用 flutter devices 查看
```

若仍失敗，請持續用 **Xcode → Product → Run** 安裝到真機。
