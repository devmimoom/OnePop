# Firebase 密碼重設郵件模板調整步驟

在 Firebase Console 中編輯「Password reset」郵件模板，可自訂顯示文字（例如說明「這是 OnePop 的重設密碼信」），連結仍會導向 Firebase 官方 action 頁完成重設，無需改程式。

---

## 一、進入 Firebase Console

1. 開啟瀏覽器，前往：**https://console.firebase.google.com**
2. 使用你的 Google 帳號登入（需有該專案的存取權限）
3. 在專案列表中點選你的專案（例如 **LearningBubbles** 或 `learningbubbles-4ffc2`）

---

## 二、開啟 Authentication 的郵件模板

1. 左側選單點 **「Build」**（或「建置」）
2. 點 **「Authentication」**（身份驗證）
3. 上方分頁點 **「Templates」**（範本／模板）
4. 在「Email address」區塊中，找到 **「Password reset」**（密碼重設）
5. 點該列右側的 **鉛筆圖示（編輯）** 或 **「⋯」→ Edit**

---

## 三、編輯郵件內容（可改的欄位）

在彈出的編輯視窗中，可調整以下欄位（僅改「顯示文字」，不影響重設連結行為）：

### 1. **Subject（主旨）**

- 預設類似：`Reset your password for [Project ID]`
- 可改為例如：`OnePop：重設密碼` 或 `Reset your OnePop password`

### 2. **Sender name（寄件者名稱）**

- 預設為專案名稱
- 可改為：`OnePop` 或 `OnePop Team`

### 3. **Reply-to email（回覆信箱，選填）**

- 若希望使用者回信時寄到你的客服信箱，可填你的 email
- 可不填，維持預設

### 4. **Body（內文）**

- 預設為 Firebase 提供的英文說明與「Reset password」按鈕
- 可改為自訂說明，例如：

  ```
  You requested a password reset for your OnePop account.

  Click the button below to set a new password. This link will expire in 1 hour.

  If you didn't request this, you can ignore this email.
  ```

- **重要**：內文裡必須保留 **「Reset password」按鈕**（或等同的 action link），Firebase 會自動插入重設連結。若使用自訂 HTML，需保留 `%LINK%` 或範本提供的連結變數，否則使用者無法點擊重設。

### 5. **Action URL（選填）**

- 若留空，預設就是 Firebase 的 action 頁（`https://...firebaseapp.com/__/auth/action?...`），**不需改**即可維持「點連結 → 官方頁面輸入新密碼」的行為
- 只有當你要改成「點連結 → 先到你的網站再處理」時，才在這裡填你的網址（進階用法，需自架網頁處理）

---

## 四、儲存

1. 編輯完成後，點視窗下方的 **「Save」**（儲存）
2. 之後 App 呼叫 `sendPasswordResetEmail(email)` 所寄出的信，就會使用新的主旨與內文

---

## 五、檢查範本變數（若用自訂 HTML）

若你選擇「自訂 HTML」編輯內文，Firebase 密碼重設範本常見變數為：

- **%LINK%**：重設密碼的連結（必須保留，否則使用者無法重設）
- **%EMAIL%**：使用者的 email（可選）
- **%APP_NAME%**：專案／App 名稱（可選）

請勿刪除 `%LINK%`，否則按鈕或連結會失效。

---

## 六、快速對照（只改品牌說明時）

| 步驟 | 位置 | 動作 |
|------|------|------|
| 1 | Firebase Console → 選專案 | 登入並選專案 |
| 2 | Build → Authentication | 進入身份驗證 |
| 3 | Authentication → Templates | 進入範本頁 |
| 4 | Email → Password reset → 編輯 | 點鉛筆／Edit |
| 5 | Subject / Sender name / Body | 改成 OnePop 相關文字，保留重設連結 |
| 6 | Action URL | 留空（維持預設 Firebase action 頁） |
| 7 | Save | 儲存 |

完成後，使用者收到的重設信就會顯示「這是 OnePop 的重設密碼信」等自訂文字，點擊連結仍會開啟 Firebase 官方頁面輸入新密碼，行為不變、僅顯示更符合你的 App 品牌。
