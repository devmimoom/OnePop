# 登入流程邏輯完整檢查報告

## 1. 流程總覽

| 流程 | 入口 | AuthService 方法 | UI 處理 | 導航 |
|------|------|------------------|---------|------|
| 匿名登入 | main() | FirebaseAuth.signInAnonymously() | 無 UI | - |
| 信箱登入 | LoginPage._submit | signInWithEmailAndPassword | SnackBar + messageFromAuthException | pop 一次 → Me |
| 信箱註冊 | RegisterPage._submit | createUserWithEmailAndPassword | SnackBar (wasAnonymous) | pop 兩次 → Me |
| Google 登入 | Login/Register _signInWithGoogle | signInWithGoogle | SnackBar；取消不顯示 | Login pop 1 / Register pop 2 |
| Apple 登入 | Login/Register _signInWithApple | signInWithApple | SnackBar；取消不顯示 | 同上 |
| 重設密碼 | ForgotPasswordPage._submit | sendPasswordResetEmail | SnackBar；成功設 _sent | 無 pop |
| 登出 | MePage._signOutAndResign | FirebaseAuth.signOut + signInAnonymously | SnackBar | 無 |

---

## 2. AuthService 邏輯檢查

### 2.1 signInWithEmailAndPassword

- **匿名時**：linkWithCredential → `SignInResult.linked`。
- **credential-already-in-use**：signOut → signInWithEmailAndPassword → `signedInToExisting`；若失敗則 signInAnonymously() 後 rethrow。正確。
- **非匿名時**：直接 signInWithEmailAndPassword → `signedIn`。正確。

### 2.2 createUserWithEmailAndPassword

- **匿名時**：linkWithCredential（無回傳，UI 用 wasAnonymous 顯示訊息）。正確。
- **非匿名時**：createUserWithEmailAndPassword。正確。
- **email-already-in-use / credential-already-in-use**：由 Firebase 拋出，UI 以 messageFromAuthException 顯示。正確。

### 2.3 signInWithGoogle

- account == null → 拋出 `sign_in_canceled`（UI 不顯示錯誤）。正確。
- idToken/accessToken 為 null → 拋出 `invalid-credential`。正確。
- 其餘 → _signInOrLinkWithCredential(cred)。正確。

### 2.4 signInWithApple

- nonce + SHA256，getAppleIDCredential，idToken 檢查，_signInOrLinkWithCredential。正確。

### 2.5 _signInOrLinkWithCredential

- **匿名時**：try linkWithCredential → linked；catch credential-already-in-use → signOut → try signInWithCredential → signedInToExisting；若 signInWithCredential 失敗則 signInAnonymously() 後 rethrow。
- **已修復**：原先 credential-already-in-use 時 signOut 後若 signInWithCredential 失敗，使用者會處於未登入狀態；已改為失敗時恢復匿名再 rethrow，與信箱登入行為一致。

### 2.6 sendPasswordResetEmail

- 空信箱拋出 invalid-email；其餘呼叫 Firebase。正確。

### 2.7 messageFromAuthException

- 涵蓋 email-already-in-use、invalid-email、operation-not-allowed、weak-password、user-disabled、user-not-found、wrong-password、invalid-credential、credential-already-in-use、requires-recent-login、too-many-requests、network-request-failed、sign_in_canceled；default 有兜底。正確。

---

## 3. UI 邏輯檢查

### 3.1 LoginPage

- **_submit**：驗證 → loading=true → signInWithEmailAndPassword → if (!mounted) return → invalidate(uidProvider) → SnackBar → pop。FirebaseAuthException → messageFromAuthException SnackBar；catch → 通用 SnackBar。finally → if (mounted) setState(loading=false)。信箱登入不呼叫 _waitForAuthNonAnonymous（Firebase 回傳時 currentUser 已更新）。正確。
- **_signInWithGoogle / _signInWithApple**：if (_loading) return；成功 → if (!mounted) return → _waitForAuthNonAnonymous() → if (!mounted) return → invalidate → SnackBar → pop。sign_in_canceled / AuthorizationErrorCode.canceled → return 不顯示；其餘錯誤 → SnackBar。finally → if (mounted) setState(loading=false)。正確。
- **_waitForAuthNonAnonymous**：authStateChanges().where(non-anonymous).first.timeout(3s)；逾時或錯誤則不阻擋，避免無限等待。正確。
- 堆疊：Me → Login，成功後 pop 一次回 Me。正確。

### 3.2 RegisterPage

- **_submit**：wasAnonymous 在呼叫 createUserWithEmailAndPassword **前**讀取，用於 SnackBar 文案；成功 → invalidate → SnackBar → pop 兩次（Register 在 Login 上層）。不呼叫 _waitForAuthNonAnonymous（createUser/link 回傳時 currentUser 已更新）。正確。
- **_signInWithGoogle / _signInWithApple**：成功 → _waitForAuthNonAnonymous → invalidate → SnackBar → pop 兩次回 Me。正確。
- 「Already have an account?」→ pop 一次回 Login。正確。
- **Validators**：信箱 empty/trim.isEmpty 或無 @ → 錯誤；密碼 empty → 錯誤；密碼 length < 6 → 錯誤；確認密碼 empty 或 != 密碼 → 錯誤。Firebase weak-password 由 messageFromAuthException 處理。正確。

### 3.3 ForgotPasswordPage

- **_submit**：成功 → setState(_loading=false, _sent=true) + SnackBar；FirebaseAuthException / catch(_) → setState(_loading=false) + SnackBar。無 finally，但三條分支皆設 _loading=false。正確。
- 按鈕 onPressed: _loading || _sent ? null → _submit；_sent 僅在成功時設為 true，故錯誤後可重試。正確。
- **Validator**：信箱 empty/trim.isEmpty 或無 @ → 錯誤。AuthService.sendPasswordResetEmail 內部 trim；空字串拋 invalid-email。正確。

### 3.4 main()

- currentUser == null → signInAnonymously()；失敗僅 debugPrint，不阻擋啟動。若匿名失敗，currentUser 仍為 null，後續讀 uidProvider 會 throw；實務上需在 Firebase 啟用匿名。正確（文件已說明）。

### 3.5 MePage _signOutAndResign 與 _handleSignOut

- **_handleSignOut**：if (_isSigningOut) return；setState(_isSigningOut=true)；try { await _signOutAndResign } finally { if (mounted) setState(_isSigningOut=false) }。若 _signOutAndResign 拋錯，_isSigningOut 仍會在 finally 還原，避免按鈕卡在 loading。已修復。
- **_signOutAndResign**：signOut() 後最多兩次 signInAnonymously()；成功 → invalidate(uidProvider) + SnackBar + return；兩次皆失敗 → SnackBar「Signed out, but could not continue as guest. Please try again.」。邏輯正確。

---

## 4. 依賴與狀態

- **uidProvider**：currentUser == null 時 throw。僅在「已有 currentUser」的畫面使用；Me 匿名時由 main() 保證有匿名使用者。正確。
- **authStateProvider**：用於 Me 顯示「匿名 / 已登入 / 信箱」。正確。
- **authServiceProvider**：Login/Register 用於 isAnonymous 按鈕文案與呼叫 AuthService。正確。

---

## 5. 已修復項目

- **AuthService._signInOrLinkWithCredential**：credential-already-in-use 時，signOut 後若 signInWithCredential(cred) 失敗，改為 signInAnonymously() 後 rethrow，避免使用者被登出且無法以訪客繼續。

---

## 6. 已修復項目（本次細部檢查）

- **MePage._handleSignOut**：改為 try { _signOutAndResign } finally { setState(_isSigningOut=false) }，避免 _signOutAndResign 拋錯時 _isSigningOut 卡住、Sign out 按鈕一直 loading。

---

## 7. 細部檢查（逐路徑／逐分支）

### 7.1 AuthService 分支

| 方法 | 分支 | 結果／拋錯 |
|------|------|------------|
| signInWithEmailAndPassword | currentUser?.isAnonymous == true + linkWithCredential 成功 | return linked |
| | 同上 + credential-already-in-use + signInWithEmailAndPassword 成功 | return signedInToExisting |
| | 同上 + credential-already-in-use + signInWithEmailAndPassword 失敗 | signInAnonymously() 後 rethrow |
| | 同上 + 其他 FirebaseAuthException | rethrow |
| | 非匿名 + signInWithEmailAndPassword 成功 | return signedIn |
| createUserWithEmailAndPassword | 匿名 + linkWithCredential | void（成功）或 throw |
| | 非匿名 + createUserWithEmailAndPassword | void（成功）或 throw |
| signInWithGoogle | account == null | throw sign_in_canceled |
| | idToken/accessToken null | throw invalid-credential |
| | 其餘 | _signInOrLinkWithCredential(cred) |
| signInWithApple | idToken null/empty | throw invalid-credential |
| | 其餘 | _signInOrLinkWithCredential(oauthCredential) |
| _signInOrLinkWithCredential | 匿名 + linkWithCredential 成功 | return linked |
| | 匿名 + credential-already-in-use + signInWithCredential 成功 | return signedInToExisting |
| | 匿名 + credential-already-in-use + signInWithCredential 失敗 | signInAnonymously() 後 rethrow |
| | 匿名 + 其他 FirebaseAuthException | rethrow |
| | 非匿名 + signInWithCredential 成功 | return signedIn |
| sendPasswordResetEmail | trimmed.isEmpty | throw invalid-email |
| | 其餘 | Firebase sendPasswordResetEmail |

### 7.2 UI Validators 與輸入

| 頁面 | 欄位 | 驗證規則 | 備註 |
|------|------|----------|------|
| Login | Email | 非空（trim）、含 @ | AuthService 內部 trim |
| Login | Password | 非空 | 長度由 Firebase 檢驗 |
| Register | Email | 同 Login | |
| Register | Password | 非空、length >= 6 | 與 Firebase weak-password 一致 |
| Register | Confirm | 非空、== Password | |
| ForgotPassword | Email | 非空（trim）、含 @ | AuthService 內部 trim，空字串拋 invalid-email |

### 7.3 錯誤處理覆蓋

| 頁面／流程 | FirebaseAuthException | SignInWithAppleAuthorizationException | catch (_) | finally loading |
|------------|------------------------|----------------------------------------|-----------|-----------------|
| Login _submit | 是，messageFromAuthException | - | 是，通用 SnackBar | 是 |
| Login _signInWithGoogle | 是；sign_in_canceled 不顯示 | - | 是 | 是 |
| Login _signInWithApple | 是；sign_in_canceled 不顯示 | 是；canceled 不顯示 | 是 | 是 |
| Register _submit | 是 | - | 是 | 是 |
| Register _signInWithGoogle/Apple | 同 Login | 同 Login | 是 | 是 |
| ForgotPassword _submit | 是，setState(_loading=false) | - | 是，setState(_loading=false) | 無（各分支已設） |

### 7.4 mounted / context.mounted 使用

- Login/Register/Forgot：在 async 回調後皆以 `if (!mounted) return` 或 `if (mounted) setState(...)` 保護，避免 dispose 後 setState。正確。
- Me _handleSignOut：finally 內 `if (mounted) setState(_isSigningOut=false)`；_signOutAndResign 內 `if (context.mounted) ScaffoldMessenger`。正確。

### 7.5 Provider 失效與讀取

- **uidProvider**：依賴 `firebaseAuthProvider.currentUser`；Firebase Auth 狀態變更時 Provider 回傳的 **instance** 不變，故需手動 `ref.invalidate(uidProvider)` 才會重新計算。Login/Register 成功後皆呼叫 invalidate(uidProvider)。正確。
- **authStateProvider**：StreamProvider(authStateChanges())，串流會自動推送，無需 invalidate。Me 頁用 authStateProvider 顯示帳號狀態。正確。
- **authServiceProvider**：回傳 AuthService(auth: firebaseAuthProvider)；AuthService 內部用 _auth.currentUser，讀取時即時取得，登入後 invalidate(uidProvider) 即足夠。Login/Register 按鈕文案用 ref.watch(authServiceProvider).isAnonymous，依賴 authState 的畫面會用 authStateProvider。正確。

### 7.6 導航堆疊與 pop 次數

- Me → Login：堆疊 [Me, Login]。Login 成功 pop() 一次 → 回 Me。正確。
- Me → Login → Register：堆疊 [Me, Login, Register]。Register 成功 pop() 兩次 → 回 Me。Register「Already have an account?」pop() 一次 → 回 Login。正確。
- Login → ForgotPassword：堆疊 [Me, Login, ForgotPassword]。ForgotPassword 不 pop（成功後使用者可手動 Back to sign in）。正確。

### 7.7 邊界情況

- **匿名失敗（main）**：currentUser 仍為 null；CreditsIAPService / setUserId 僅在 currentUser != null 時呼叫；任何讀取 uidProvider 的畫面會 throw。文件已說明需啟用匿名。正確。
- **Apple SignInWithAppleAuthorizationException.message**：已修復；Login/Register 皆改為 `e.message.isNotEmpty ? e.message : 'Something went wrong. Please try again.'`，避免空字串時顯示異常（e.message 為非 nullable String）。正確。
- **Register wasAnonymous**：在呼叫 createUserWithEmailAndPassword **前**讀取；若為匿名則顯示 "Account upgraded."，否則 "Signed up successfully."。正確。

---

## 8. 建議（非必須）

- Me 頁可考慮改為呼叫 AuthService.signOut() 以集中登出邏輯，目前行為與直接呼叫 Firebase 一致。

---

## 9. 完整邏輯檢查（無遺漏）

### 9.1 currentUser 三種狀態下的 AuthService 行為

| AuthService 方法 | currentUser == null | currentUser 匿名 | currentUser 非匿名 |
|------------------|---------------------|------------------|---------------------|
| signInWithEmailAndPassword | 走 else：signInWithEmailAndPassword → signedIn | 走 if：link 或 credential-already-in-use 處理 | 走 else：signIn → signedIn |
| createUserWithEmailAndPassword | 走 else：createUserWithEmailAndPassword | 走 if：linkWithCredential | 走 else：createUser |
| signInWithGoogle | 不讀 currentUser；account/auth 後 _signInOrLinkWithCredential；走 else：signInWithCredential → signedIn | 走 if：link 或 credential-already-in-use 處理 | 走 else：signInWithCredential → signedIn |
| signInWithApple | 同上 | 同上 | 同上 |
| _signInOrLinkWithCredential | currentUser?.isAnonymous == true 為 false（null?.isAnonymous 為 null），走 else：signInWithCredential | 走 if：link 或 credential-already-in-use | 走 else：signInWithCredential |
| sendPasswordResetEmail | 不依賴 currentUser | 不依賴 | 不依賴 |
| isAnonymous getter | currentUser?.isAnonymous ?? true → true | true/false 依實際 | false |

結論：currentUser == null 時，信箱/Google/Apple 皆走「一般登入／註冊」分支，不會誤走 link；isAnonymous 為 true 僅影響 UI 按鈕文案。邏輯一致。

### 9.2 例外類型與 UI 捕捉

| 來源 | 例外類型 | Login | Register | ForgotPassword |
|------|----------|-------|----------|----------------|
| signInWithEmailAndPassword | FirebaseAuthException | on catch，messageFromAuthException | - | - |
| | 其他（網路、平台） | catch (_)，通用 SnackBar | - | - |
| createUserWithEmailAndPassword | FirebaseAuthException | - | on catch，messageFromAuthException | - |
| | 其他 | - | catch (_)，通用 SnackBar | - |
| signInWithGoogle | FirebaseAuthException（含 sign_in_canceled） | on catch；canceled 不顯示 | 同左 | - |
| | 其他 | catch (_) | 同左 | - |
| signInWithApple | FirebaseAuthException | 同 Google | 同左 | - |
| | SignInWithAppleAuthorizationException | on catch；canceled 不顯示；e.message 已 null-safe | 同左 | - |
| | 其他 | catch (_) | 同左 | - |
| sendPasswordResetEmail | FirebaseAuthException | - | - | on catch，messageFromAuthException |
| | 其他 | - | - | catch (_) |

結論：所有 AuthService 可能拋出的例外皆有對應 UI 處理；取消類（sign_in_canceled、AuthorizationErrorCode.canceled）不顯示錯誤；其餘皆顯示 SnackBar。無未捕捉路徑。

### 9.3 狀態變數完整生命週期

| 頁面 | 變數 | 設為 true／1 | 設為 false／0 | 遺漏風險 |
|------|------|-------------|--------------|----------|
| Login | _loading | _submit / _signInWithGoogle / _signInWithApple 開頭 | finally（所有路徑） | 無；finally 保證 |
| Register | _loading | 同上 | finally 或各 catch 內 | 無 |
| ForgotPassword | _loading | _submit 開頭 | 成功 setState、FirebaseAuthException、catch(_) | 無；三分支皆設 |
| ForgotPassword | _sent | 僅成功 setState | 永不設回 false | 正確；成功後不重送 |
| MePage | _isSigningOut | _handleSignOut 開頭 | finally（含 _signOutAndResign 拋錯） | 無；try/finally 保證 |

結論：無任何路徑會讓 _loading 或 _isSigningOut 永久為 true；_sent 僅在成功時設為 true，符合預期。

### 9.4 假設與前置條件（文件化）

- **導航堆疊**：Register 僅由 Login 進入，堆疊為 Me → Login → Register；故 Register 成功後 pop 兩次回 Me。若日後新增「Me 直接進 Register」，需依進入路徑調整 pop 次數（見 Register 註解）。
- **Firebase Console**：匿名、電子郵件/密碼、Google、Apple 皆已啟用；否則會出現 operation-not-allowed 或匿名失敗。見 AUTH_SETUP.md。
- **平台**：Apple 登入按鈕僅在 Platform.isIOS 時顯示；Android 目前 firebase_options 未設定，登入流程以 iOS 為準。
- **uidProvider**：任何「讀取 uidProvider」的畫面必須在「已有 currentUser」時才進入；目前由 main() 匿名登入與 Me 入口保證，匿名失敗時可能 crash，需啟用匿名避免。

### 9.5 messageFromAuthException 與 e.code 為 null

- FirebaseAuthException.code 理論上可為 null；switch(e.code) 會走到 default，回傳 'Something went wrong. Please try again.'。無需額外 null 檢查。

### 9.6 已修復項目（本次完整檢查）

- **SignInWithAppleAuthorizationException.message**：LoginPage 與 RegisterPage 在顯示 Apple 錯誤時改為 `e.message.isNotEmpty ? e.message : 'Something went wrong. Please try again.'`，避免 e.message 為空字串時顯示異常。
