# iOS 專案完整檢查報告

本文件為 iOS 目錄與相關設定的逐項檢查，包含 Info.plist、AppDelegate、entitlements、Podfile、Xcode 專案、Storyboard 及與 Flutter 的對應關係。

---

## 1. 目錄結構

```
ios/
├── .gitignore
├── Flutter/
│   ├── AppFrameworkInfo.plist
│   ├── Debug.xcconfig
│   └── Release.xcconfig
├── Podfile
├── Podfile.lock
├── Runner/
│   ├── AppDelegate.swift
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/   (多尺寸圖示)
│   │   └── LaunchImage.imageset/
│   ├── Base.lproj/
│   │   ├── LaunchScreen.storyboard
│   │   └── Main.storyboard
│   ├── GoogleService-Info.plist
│   ├── Info.plist
│   ├── Runner-Bridging-Header.h
│   └── Runner.entitlements
├── Runner.xcodeproj/
│   └── project.pbxproj
├── Runner.xcworkspace/
└── RunnerTests/
    └── RunnerTests.swift
```

結論：結構完整，無缺檔。

---

## 2. Info.plist（Runner/Info.plist）

| 鍵 | 值／說明 | 狀態 |
|----|----------|------|
| CFBundleDisplayName | OnePop | OK |
| CFBundleName | OnePop | OK |
| CFBundleIdentifier | $(PRODUCT_BUNDLE_IDENTIFIER) → 實際為 com.mimoom.onepop（見 project.pbxproj） | OK |
| CFBundleShortVersionString | $(FLUTTER_BUILD_NAME) | OK |
| CFBundleVersion | $(FLUTTER_BUILD_NUMBER) | OK |
| UILaunchStoryboardName | LaunchScreen | OK |
| UIMainStoryboardFile | Main | OK |
| NSUserNotificationUsageDescription | "We use notifications to deliver daily content from OnePop." | OK（通知用途說明） |
| CFBundleURLTypes | Google Sign-In URL scheme（GIDClientID 對應） | OK |
| UISupportedInterfaceOrientations | Portrait, Landscape L/R | OK |
| UISupportedInterfaceOrientations~ipad | Portrait, PortraitUpsideDown, Landscape L/R | OK |
| LSRequiresIPhoneOS | true | OK |
| CADisableMinimumFrameDurationOnPhone | true | OK |
| UIApplicationSupportsIndirectInputEvents | true | OK |

注意：iOS 10+ 通知權限對話由系統提供，無法自訂文案；NSUserNotificationUsageDescription 仍可保留作為說明用途（部分文件指其於 macOS 使用，iOS 上不影響功能）。

結論：Info.plist 設定完整，與 App 名稱、通知、Google 登入、方向一致。

---

## 3. AppDelegate.swift

| 項目 | 內容 | 狀態 |
|------|------|------|
| 繼承 | FlutterAppDelegate | OK |
| didFinishLaunchingWithOptions | GeneratedPluginRegistrant.register；設定 UNUserNotificationCenter.current().delegate = self（iOS 10+） | OK |
| userNotificationCenter(_:willPresent:withCompletionHandler:) | 前景收到通知時：iOS 14+ 回傳 [.banner, .sound, .badge]；否則 [.alert, .sound, .badge] | OK（前景橫幅會顯示） |
| userNotificationCenter(_:didReceive:withCompletionHandler:) | 點擊／滑掉通知時列印除錯日誌，並呼叫 super 讓 Flutter 處理 | OK |

與 Flutter 的對應：

- lib 中 `DarwinNotificationDetails` 的 categoryIdentifier（bubble_actions_v2、completion_actions_v1）與原生端無須再設定，由 flutter_local_notifications 註冊。
- 前景顯示由 AppDelegate 的 willPresent 決定，目前會顯示橫幅、聲音、角標。

結論：通知委派與前景顯示設定正確，無需修改。

---

## 4. Runner.entitlements

| 鍵 | 值 | 狀態 |
|----|-----|------|
| com.apple.developer.applesignin | Default | OK（Sign in with Apple） |

未啟用：Push Notifications、Background Modes（例如 remote-notification）。本專案使用本地通知（flutter_local_notifications），不需 Push Notifications capability；若未來改為 APNs 遠端推播，再於 Xcode 加入 Push Notifications 與對應後端。

結論：目前僅需 Sign in with Apple，設定正確。

---

## 5. Podfile

| 項目 | 內容 | 狀態 |
|------|------|------|
| platform | :ios, '13.0' | OK（與 project.pbxproj IPHONEOS_DEPLOYMENT_TARGET 13.0 一致） |
| use_frameworks! | 有 | OK |
| 手動 pod | GTMSessionFetcher/Core ~> 3.4（解決 firebase_auth 與 google_sign_in_ios 衝突） | OK |
| post_install | 所有 Pod 的 IPHONEOS_DEPLOYMENT_TARGET 至少 12.0 | OK |

結論：iOS 13、依賴與部署目標一致，無衝突。

---

## 6. Xcode 專案（project.pbxproj）

| 項目 | Debug / Release / Profile（Runner target） | 狀態 |
|------|--------------------------------------------|------|
| ASSETCATALOG_COMPILER_APPICON_NAME | AppIcon | OK |
| CODE_SIGN_ENTITLEMENTS | Runner/Runner.entitlements | OK |
| INFOPLIST_FILE | Runner/Info.plist | OK |
| PRODUCT_BUNDLE_IDENTIFIER | com.mimoom.onepop | OK |
| SWIFT_OBJC_BRIDGING_HEADER | Runner/Runner-Bridging-Header.h | OK |
| SWIFT_VERSION | 5.0 | OK |
| DEVELOPMENT_TEAM | H7TSDR937Y | OK（需與實際 Apple 開發者帳號一致） |
| IPHONEOS_DEPLOYMENT_TARGET（專案層） | 13.0 | OK |

RunnerTests：PRODUCT_BUNDLE_IDENTIFIER 為 com.example.learningbubbles.RunnerTests，與主 App 分離，正確。

結論：Runner 與 RunnerTests 設定正確，bundle id 與 firebase_options.dart 的 iosBundleId（com.mimoom.onepop）一致。

---

## 7. Flutter 設定（ios/Flutter/*.xcconfig）

- Debug.xcconfig / Release.xcconfig：僅 include Pods 與 Generated.xcconfig，無自訂鍵。
- Generated.xcconfig 由 `flutter pub get` / build 產生，未手動修改。

結論：符合 Flutter 預設，無需變更。

---

## 8. Runner-Bridging-Header.h

僅 `#import "GeneratedPluginRegistrant.h"`，供 Swift 使用 Flutter 插件。正確。

---

## 9. Storyboard

- **Main.storyboard**：單一 FlutterViewController，為 Flutter 預設主畫面。OK。
- **LaunchScreen.storyboard**：單一 View Controller，中央 LaunchImage。OK。

結論：入口與啟動畫面設定正確。

---

## 10. Flutter 端與 iOS 對應

| Flutter／檔案 | iOS 對應 | 狀態 |
|---------------|----------|------|
| firebase_options.dart iosBundleId | com.mimoom.onepop | 與 Xcode PRODUCT_BUNDLE_IDENTIFIER 一致 |
| notification_service.dart | requestPermissions(alert, badge, sound)；DarwinNotificationDetails 使用 bubble_actions_v2、completion_actions_v1 | 與 AppDelegate 前景顯示、Flutter 插件行為一致 |
| Platform.isIOS（onboarding） | 判斷是否顯示 iOS 通知指引頁 | OK |
| Theme.of(context).platform == TargetPlatform.iOS（me_page） | 是否顯示「iOS 通知設定建議」 | OK |
| push_orchestrator iosSafeMaxScheduled: 60 | iOS 排程上限 64 以內 | OK |

結論：bundle id、通知流程、平台判斷與排程上限均與 iOS 設定一致。

---

## 11. 總結

- **Info.plist**：App 名稱、版本、通知說明、Google URL scheme、方向、Launch/Main storyboard 皆正確。
- **AppDelegate**：通知委派、前景橫幅／聲音／角標、點擊與滑掉回調正確，並交由 Flutter 處理。
- **Runner.entitlements**：僅 Sign in with Apple，符合目前功能。
- **Podfile**：iOS 13、GTMSessionFetcher、部署目標 12.0 以上，無衝突。
- **project.pbxproj**：Bundle ID com.mimoom.onepop、entitlements、Info.plist、Swift 5、deployment target 13.0、DEVELOPMENT_TEAM 設定正確。
- **Storyboard / Bridging Header / Flutter xcconfig**：皆為標準設定，無缺漏或錯誤。

整體 iOS 專案設定完整且一致，無發現錯誤或遺漏；若要上架或真機安裝，僅需在 Xcode 中確認 Signing & Capabilities 的 Team 與實際帳號相符，並依 INSTALL_IOS_TROUBLESHOOTING.md 處理簽章與信任即可。
