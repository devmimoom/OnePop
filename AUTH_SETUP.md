# 登入流程設定檢查清單

本專案使用 Firebase Authentication，支援匿名、信箱/密碼、Google、Apple 登入。請依下列步驟確認環境設定正確，避免出現「sign in method is not enabled」等錯誤。

## 1. Firebase Console

1. 開啟 [Firebase Console](https://console.firebase.google.com/)。
2. 確認左上角選取的專案為 **`learningbubbles-4ffc2`**（與 `lib/firebase_options.dart` 中的 `projectId` 一致）。
3. 左側選 **Build** → **Authentication**，上方分頁選 **Sign-in method**。
4. 在「登入資訊提供者」中，確認以下項目皆為 **已啟用**（綠色勾勾）並已按 **儲存**：
   - **匿名**：未啟用時，App 啟動時匿名登入會失敗。
   - **電子郵件/密碼**：未啟用時，信箱登入/註冊會出現「sign in method is not enabled」。
   - **Google**：未啟用時，Google 登入會出現同上錯誤。
   - **Apple**：未啟用時，Apple 登入會出現同上錯誤。
5. 若某項不在清單中，點 **新增供應商**，選擇該方式後啟用並儲存。

## 2. iOS 原生設定

- **Google Sign-In**：`ios/Runner/Info.plist` 已包含 `GIDClientID` 與 `CFBundleURLTypes`（Google Sign-In URL scheme），無需額外設定。
- **Sign in with Apple**：
  1. 用 Xcode 開啟 `ios/Runner.xcworkspace`（勿開 `.xcodeproj`）。
  2. 左側選 **Runner** target，上方選 **Signing & Capabilities**。
  3. 確認已有 **Sign in with Apple** 能力；若無，點 **+ Capability**，搜尋並加入「Sign in with Apple」。
  4. 存檔後關閉 Xcode。

## 3. 目前支援平台

- **iOS**：登入流程（匿名、信箱/密碼、Google、Apple、重設密碼、登出）已完整支援。
- **Android**：目前 `lib/firebase_options.dart` 未設定 Android 的 Firebase Options，在 Android 上執行會拋出 `UnsupportedError`，等同登入流程尚未在 Android 啟用。若需支援 Android，請在專案中執行 FlutterFire CLI（例如 `dart run flutterfire_cli:flutterfire configure`），勾選 Android 並完成設定，再於 Firebase Console 加入 Android App。

## 4. 驗證步驟（設定完成後手動測試）

1. **Firebase**：確認四種供應商（匿名、電子郵件/密碼、Google、Apple）皆已啟用並儲存。
2. **信箱登入**：Login 頁輸入已註冊信箱/密碼，預期成功並返回；錯誤時應顯示明確訊息（若為「未啟用」會引導至 Firebase Console）。
3. **信箱註冊**：Register 頁輸入新信箱/密碼，預期成功並返回 Me 頁；若信箱已存在，應顯示對應錯誤訊息。
4. **Google**：Login 或 Register 點「Sign in with Google」，預期可選帳號並登入；取消時不顯示錯誤。
5. **Apple**：iOS 上點「Sign in with Apple」，預期可完成或取消；取消時不顯示錯誤。
6. **重設密碼**：Forgot password 頁輸入信箱，預期顯示「Password reset email sent」。
7. **登出**：Me 頁已登入狀態點 Sign out，預期變回匿名並顯示「Signed out. You are now signed in as a new guest.」
8. **匿名**：完全關閉 App 再開，預期自動匿名登入，Me 頁顯示「Upgrade account」。
