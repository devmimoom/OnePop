# Notification Tutorial 整合 — 邏輯與流程檢查

## 1. 檔案與依賴

| 檔案 | 用途 |
|------|------|
| `lib/pages/notification_tutorial_page.dart` | 四步教學頁（橫幅／時段／互動／設定），完成或跳過時寫入 store |
| `lib/pages/welcome/notification_tutorial_store.dart` | 共用 key `notification_tutorial_completed`、`getNotificationTutorialCompleted()`、`setNotificationTutorialComplete()` |
| `lib/pages/welcome/onboarding_screen.dart` | Slide3 的 Next 改為先推教學，pop 後再 `_nextPage()` 到 Slide4 |
| `lib/pages/me_page.dart` | Notifications 點擊先讀完成狀態，未完成則先推教學再推 PushCenterPage |

- **ProviderScope**：`main.dart` 以 `ProviderScope` 包住 app，`NotificationTutorialPage`（ConsumerStatefulWidget）可正常使用 `ref`。
- **Import**：onboarding 用 `../notification_tutorial_page.dart`（welcome → pages）；me_page 用 `notification_tutorial_page.dart`、`welcome/notification_tutorial_store.dart`，路徑正確。

---

## 2. Onboarding 流程（Slide3 → Slide4）

1. 使用者在 **Slide3** 點「Next」→ 呼叫 `() => _onSlide3Next()`（VoidCallback 合法）。
2. **`_onSlide3Next()`**：  
   `await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationTutorialPage(isFirstTime: true)))`  
   堆疊：`[OnboardingScreen, NotificationTutorialPage]`。
3. 教學頁行為：
   - **跳過**（僅 isFirstTime 且非最後一頁時顯示）：`_skipTutorial()` → `setNotificationTutorialComplete()` → `pop()`。
   - **最後一頁「開始使用 OnePop」**：`_finishTutorial()` → `setNotificationTutorialComplete()` → `pop()`。
   - **系統返回**（Android 返回／iOS 邊緣滑動）：直接 `pop()`，**不**寫入完成狀態。
4. 教學頁 pop 後，`_onSlide3Next()` 的 `await` 結束，執行 `if (mounted) _nextPage()`。
5. **`_nextPage()`**：讀取 `onboardingStateProvider.currentPage`（仍為 2），`2 < 3`，呼叫 `_pageController.nextPage(...)`，PageView 從 index 2 動到 3（Slide4）；`onPageChanged(3)` 會把 state 設為 3。
6. 結果：無論教學是「完成／跳過」或「系統返回」，都會進入 **Slide4**；只有完成或跳過時會把 `notification_tutorial_completed` 設為 true。

**結論**：Onboarding 流程與 state／PageController 同步正確；系統返回不標記完成，之後從 Me 進 Notifications 會再看到教學，邏輯一致。

---

## 3. Me → Notifications 流程

1. 使用者點 **Notifications** → `onTap` 為 async。
2. `completed = await getNotificationTutorialCompleted()`（讀取 `notification_tutorial_completed`）。
3. `if (!context.mounted) return;` 避免非同步後 context 失效。
4. **若 completed == true**：直接 `Navigator.push(PushCenterPage())`。
5. **若 completed == false**：  
   - `await Navigator.push(NotificationTutorialPage(isFirstTime: false))`  
   - 教學頁無「跳過」按鈕（因 `isFirstTime == false`），只能：  
     - 走完四步並按「開始使用 OnePop」→ `_finishTutorial()` → 寫入完成 → pop；或  
     - 系統返回 → pop（不寫入完成）。  
   - pop 後 `if (context.mounted) Navigator.push(PushCenterPage())`。  
   因此：不論如何離開教學，都會再推 **PushCenterPage**；只有「開始使用 OnePop」會讓下次從 Me 進 Notifications 時不再顯示教學。

**結論**：Me 流程與完成狀態、mounted 檢查一致；未完成時先教學再進設定，完成後直接進設定。

---

## 4. 教學頁內部邏輯

- **完成狀態**：僅在 `_skipTutorial()` 與 `_finishTutorial()` 中呼叫 `_markTutorialComplete()` → `setNotificationTutorialComplete()`；系統返回不寫入，符合「使用者明確完成或跳過才標記」。
- **mounted**：`_skipTutorial`、`_finishTutorial` 在 `pop()` 前都有 `if (mounted)`，避免 dispose 後操作。
- **dispose**：`_pageController.dispose()` 在 `dispose()` 中呼叫，無洩漏。
- **`_finishTutorial`**：已簡化為一律 `pop()`，不再區分 isFirstTime（行為相同）。

---

## 5. Store 與 Key 一致性

- **Key**：`notification_tutorial_store.dart` 中 `notificationTutorialCompletedKey = 'notification_tutorial_completed'`，與文件／計畫一致。
- **讀寫**：  
  - 教學頁只寫：`setNotificationTutorialComplete()`。  
  - Me 頁只讀：`getNotificationTutorialCompleted()`。  
  無重複字串、無直接使用 SharedPreferences，邏輯集中於 store。

---

## 6. 邊界情況摘要

| 情境 | 行為 |
|------|------|
| Onboarding 教學中按系統返回 | 回到 Slide3，再按 Next 會再進教學；之後 Me → Notifications 仍會先顯示教學（未標記完成）。 |
| Me 未完成教學時按系統返回 | 仍會推 PushCenterPage；下次 Me → Notifications 會再顯示教學。 |
| 已完成教學後 Me → Notifications | 直接進入 PushCenterPage，不再顯示教學。 |
| Onboarding 完成或跳過教學 | 標記完成，進入 Slide4；之後 Me → Notifications 直接進 PushCenterPage。 |

---

## 7. 檢查結果

- **Onboarding**：Slide3 Next → 教學 → pop → Slide4；state 與 PageView 同步；mounted 與非同步處理正確。
- **Me**：依完成狀態決定先教學或直接 PushCenter；context.mounted 與雙重 push 順序正確。
- **教學頁**：完成／跳過寫入 store，dispose 與 mounted 無誤；_finishTutorial 已簡化。
- **Store**：key 與讀寫單一、與教學／Me 一致。

整體邏輯與流程完整、一致，無遺漏或矛盾。
