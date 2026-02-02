# 忘記密碼信收不到 — 檢查清單

## 1. 收件匣與垃圾信

- **先看垃圾信／促銷／社交**：Firebase 預設寄件者常被 Gmail 等歸到垃圾信。
- **等 2–5 分鐘**：有時會延遲送達。

## 2. 信箱是否正確

- 必須輸入**當初註冊／登入時用的同一個 email**（與 Firebase 帳號裡顯示的完全一致）。
- 若帳號是用 **Google / Apple 登入**，請用該服務顯示的 email（例如 `dev.mimoom@gmail.com`）。
- Firebase 為避免洩漏帳號是否存在，**若該 email 沒有對應帳號，仍會顯示「已送出」但不會真的寄信**，所以信箱打錯或沒註冊過就收不到。

## 3. Firebase Console 設定

1. **啟用 Email/密碼登入**  
   [Firebase Console](https://console.firebase.google.com) → 專案 → **Authentication** → **Sign-in method** → 啟用 **Email/Password**。

2. **重設密碼信範本（可選）**  
   **Authentication** → **Templates** → **Password reset**：  
   - 可自訂寄件者名稱與信件內容，有助於減少被當成垃圾信。  
   - 確認沒有被停用或改壞。

3. **網域與寄信**  
   若使用自訂網域或進階寄信，需在 Firebase / 對應服務裡完成驗證，否則信可能發不出去或被擋。

## 4. 開發／測試時

- 用**已在 Firebase Authentication 裡存在的使用者 email** 測試（例如已在 App 用該 email 註冊或 Google 登入過）。
- 確認 App 端沒有把錯誤吃掉：若 `sendPasswordResetEmail` 拋錯，畫面上應會顯示錯誤訊息。

---

**總結**：多數情況是信在垃圾信，或輸入的 email 與帳號不符。先檢查垃圾信、確認信箱正確，再對照上述 Firebase 設定。
