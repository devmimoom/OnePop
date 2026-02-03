# 搜尋邏輯檢查報告

本文件檢查所有搜尋相關程式碼的邏輯一致性與潛在問題。

---

## 1. 資料流總覽

```
使用者輸入 query
    → searchQueryProvider.state = query
    → searchResultsProvider 依 query 重新計算
        → repo.searchProductsPrefix(q)     [標題前綴，依 titleLower]
        → repo.searchProductsByContent(q)  [預覽內容包含關鍵字]
        → 合併去重 (標題優先)
    → search_page 取得 results.when(data: products)
    → 套用 chip filters: owned / push / wish / level
    → 套用 _applyFiltersAndSort: filter (topicIds, levels, onlyPurchased, onlyPushing) + sort
    → 顯示 filtered 列表
```

---

## 2. 後端搜尋 (lib/data/repository.dart)

### 2.1 searchProductsPrefix (約 479–501 行)

- **邏輯**：Firestore 查詢 `products`，條件：
  - `published == true`
  - `titleLower >= queryLower` 且 `titleLower < queryLower + '\uf8ff'`
  - 依 `titleLower` 排序，limit 20
- **依賴**：產品文件必須有 `titleLower` 欄位（小寫標題）。若無則查不到任何結果。
- **結論**：邏輯正確；需確保上傳腳本一律寫入 `titleLower`（做法 A 已實作）。

### 2.2 searchProductsByContent (約 505–560 行)

- **邏輯**：
  1. 取得所有 `content_items` 且 `isPreview == true`
  2. 客戶端過濾：`content.toLowerCase().contains(queryLower)` → 收集 `productId`
  3. 分批用 `whereIn` 查 `products`，只保留 `published == true` 的 ID
- **結論**：邏輯正確。注意：若預覽內容很多，一次拉全部再過濾可能較耗資源，屬既有取捨。

---

## 3. Provider 層 (lib/providers/v2_providers.dart)

### 3.1 searchResultsProvider (約 77–114 行)

- **邏輯**：`q.isEmpty` 回傳 `[]`；否則依序呼叫 `searchProductsPrefix(q)`、`searchProductsByContent(q)`，標題結果先加入、內容結果後加入，用 `seenIds` 去重。
- **結論**：合併與去重邏輯正確，標題優先順序合理。

### 3.2 搜尋用 Filter 枚舉 (約 116–131 行)

- `SearchLevelFilter`: all, foundation, practical, deepDive, specialized — 與目前 Firebase level 值 (Foundation, Practical, Deep Dive, Specialized) 一致。
- **結論**：枚舉與實際資料對齊。

---

## 4. 搜尋頁 (lib/pages/search_page.dart)

### 4.1 空 query 行為 (約 510–556 行)

- `query.isEmpty` 時顯示歷史 + 建議 + For You，不顯示搜尋結果列表。
- `searchResultsProvider` 在 `q.isEmpty` 時回傳 `[]`，故 `productsRaw` 為空時不會誤用。
- **結論**：空查詢分支正確。

### 4.2 篩選順序 (約 584–631 行)

1. 先套用 chip：`ownedFilter` → `pushFilter` → `wishFilter` → `levelFilter` (matchLevel)
2. 再套用 `_applyFiltersAndSort`：`filter.topicIds`、`filter.levels`、`onlyPurchased`、`onlyPushing`，以及 `sort`。

兩套 level 機制並存：

- **Chip level** (`SearchLevelFilter`)：foundation / practical / deepDive / specialized，用 `lv.contains('foundation')` 等字串包含比對。
- **Sheet level** (`_SearchFilterState.levels`)：從「目前搜尋結果」萃取出的 level 字串集合，在 `_applyFiltersAndSort` 裡用 `filter.levels.contains(lv)` 精確比對。

若同時選了 chip 的 Foundation 與 sheet 的 Deep Dive，會先被 chip 篩成僅 Foundation，再被 sheet 篩一次（通常會變空）。邏輯一致，僅為重複篩選。

- **結論**：順序與重複篩選行為正確。

### 4.3 matchLevel (約 602–616 行)

- `lv = (p.level ?? '').toString().toLowerCase()`
- all → 恆真；foundation → `lv.contains('foundation')`；practical → `lv.contains('practical')`；deepDive → `lv.contains('deep')`；specialized → `lv.contains('specialized')`。

注意：`deepDive` 用 `contains('deep')`，會一併匹配 "Deep Dive" 以外的含 "deep" 字串（若未來有 "deep" 或 "deeper" 等 level）。目前若 Firestore 僅有 "Deep Dive"，則無誤。

- **結論**：與現有 level 值一致；若未來新增易混淆字串，可改為 `lv.contains('deep dive')` 或精確比對。

### 4.4 _applyFiltersAndSort (約 227–274 行)

- **Filter**：`topicIds`、`levels`（精確 match）、`onlyPurchased`、`onlyPushing` 皆正確。
- **Sort**：relevant 保持原序；title 依 `(a.title ?? '').toString()` 字串比較；level 依 `(a.level ?? '').toString()` 字串比較。
- **結論**：篩選與排序邏輯正確。

### 4.5 空結果文案 (約 737–765 行)

- `products.isEmpty` → "No results for \"$query\""（搜尋本身無結果）。
- `filtered.isEmpty` 且 products 非空 → "Filters applied, but no matching results"（有結果但被篩掉）。
- **結論**：兩種情況區分正確。

### 4.6 產品來源與欄位 (約 556、784–827 行)

- `products` 來自 `searchResultsProvider`，型別為 `lib/data/models.dart` 的 `Product`。
- 列表顯示使用 `product.id`、`product.title`、`product.topicId`、`product.level`，皆為 Product 既有欄位。
- **結論**：資料來源與顯示欄位一致。

---

## 5. Product 模型 (lib/data/models.dart)

- `Product.fromDoc` 的 `level` 來自 `m['level'] ?? 'L1'`。
- 若 Firestore 使用 "Foundation"、"Practical" 等，則 `product.level` 即為該字串，與 matchLevel 及 sort by level 一致。
- **結論**：未讀取 `productLevel` 不影響目前搜尋邏輯；若未來後端改為只提供 `productLevel`，需在 fromDoc 改為使用該欄位。

---

## 6. 其他檔案

### 6.1 lib/widgets/rich_sections/search/search_filters.dart

- 定義另一組 `SearchSort`（relevance, newest, titleAZ）與 `SearchFilters` 類別。
- **搜尋頁未使用**：search_page 使用自己的 `SearchSort`（relevant, title, level）與 `_SearchFilterState`。
- **結論**：為獨立元件，不影響目前搜尋頁邏輯；若未來要統一排序選項，可考慮合併枚舉與文案。

### 6.2 fetchSearchSuggestions (lib/data/repository.dart 約 305–325 行)

- 讀取 `ui/search_suggestions_v1`，回傳 suggested / trending 字串列表；失敗時回傳預設值。
- **結論**：僅供建議區塊使用，不影響搜尋結果邏輯。

---

## 7. 總結

| 項目 | 狀態 | 備註 |
|------|------|------|
| 標題前綴搜尋 (titleLower) | 正確 | 依賴 Firestore 有 titleLower |
| 內容包含搜尋 (預覽) | 正確 | 客戶端 contains，邏輯清楚 |
| 結果合併與去重 | 正確 | 標題優先、ID 去重 |
| Level chip (Foundation / Practical / Deep Dive / Specialized) | 正確 | 與現有 level 值一致 |
| matchLevel 使用 contains | 正確 | deepDive 用 'deep' 可考慮改為 'deep dive' 更精確 |
| _applyFiltersAndSort (topic/level/purchased/pushing + sort) | 正確 | 無邏輯錯誤 |
| 空 query / 空結果 / 篩選後空結果 | 正確 | 三種情境區分正確 |
| Product.level 來源 | 正確 | 目前為 m['level']，與 Firestore 一致 |
| search_filters.dart 與 search_page | 無衝突 | 兩套 API，搜尋頁未引用 search_filters 的 Sort |

整體搜尋邏輯一致且正確；唯一前置條件為 Firestore 產品文件需具備 `titleLower`（上傳腳本已改為一律寫入）。

---

## 8. Filter 頁籤（篩選 sheet）修正（已修復）

### 問題

- 在 `_openFilterSheet` 內使用 `StatefulBuilder`，且 `var draft = cur` 在 builder 開頭執行。
- 每次 rebuild（例如點 chip 觸發 `setState`）都會重新執行 `var draft = cur`，**draft 被重置為 cur**，使用者在 sheet 內的選擇（topicIds、levels、onlyPurchased、onlyPushing）全部遺失。
- 按「Apply」時寫入 provider 的是重置後的 draft（= cur），因此篩選不會生效。

### 修正方式

- 改為使用 **`ValueNotifier<_SearchFilterState>`** 保存 draft，並用 **ValueListenableBuilder** 建構 UI。
- `draftNotifier` 在打開 sheet 時建立一次（`ValueNotifier(cur)`），chips / Switch 的 onToggle / onChanged 只更新 `draftNotifier.value`，不再依賴會重置的區域變數。
- 「Clear」設為 `draftNotifier.value = const _SearchFilterState()`；「Apply」設為 `ref.read(_searchFilterProvider.notifier).state = draftNotifier.value` 後關閉 sheet。
- 如此 draft 在 rebuild 間會保留，Filter 頁籤的選擇會正確反映並套用到搜尋結果。

---

## 9. 再次完整檢查（Full re-check）

### 9.1 Filter sheet（ValueNotifier 修正後）

- **draftNotifier**：在 `_openFilterSheet` 內、`showModalBottomSheet` 前建立一次，`ValueNotifier(cur)`，不會在 rebuild 時重置。
- **ValueListenableBuilder**：`valueListenable: draftNotifier`，`builder: (context, draft, _)` 的 `draft` 來自 notifier，chips / Switch 顯示與 `draft` 一致。
- **更新路徑**：Category chip `onToggle` → `draftNotifier.value = draft.copyWith(topicIds: next)`；Level chip → `draft.copyWith(levels: next)`；Switch onlyPurchased / onlyPushing → `draft.copyWith(onlyPurchased: v)` 等；Clear → `draftNotifier.value = const _SearchFilterState()`；Apply → `ref.read(_searchFilterProvider.notifier).state = draftNotifier.value` 後 `Navigator.pop`。
- **結論**：Filter 頁籤狀態會正確保留並寫回 provider，篩選會生效。

### 9.2 已購買 / 推播中 兩套來源

- **Chip 篩選**（Purchased / Notifications on）：使用 `purchasedSet`、`pushingSet`，來自 **libAsync2**（`libraryProductsProvider`，v2）。
- **Sheet 篩選**（Purchased only / Notifications on only）：`_applyFiltersAndSort` 使用 `purchasedSetOld`、`pushingSetOld`，來自 **lib**（`libAsync.valueOrNull`，即 `_watchLibrarySafe` → v1 `libraryProductsProvider`）。
- 若 v1 與 v2 資料不同，chip 與 sheet 的「已購買/推播中」可能不一致；屬既有設計（v1 為 fallback），邏輯一致。

### 9.3 資料流與空狀態

- `filter`、`sort` 來自 `ref.watch(_searchFilterProvider)`、`ref.watch(_searchSortProvider)`，Apply 後會觸發 rebuild，列表會依新 filter/sort 更新。
- `filter.isEmpty` 正確：`topicIds.isEmpty && levels.isEmpty && !onlyPurchased && !onlyPushing`，用於「Filters (applied)」標籤。
- `products.isEmpty` → 顯示 "No results for \"$query\""；`filtered.isEmpty` 且 products 非空 → "Filters applied, but no matching results"。兩者區分正確。

### 9.4 總結

| 檢查項 | 結果 |
|--------|------|
| Filter sheet draft 持久化 (ValueNotifier) | 已修正，邏輯正確 |
| 篩選順序 (chip → _applyFiltersAndSort) | 正確 |
| Sheet topicIds / levels 精確比對 | 正確 |
| purchasedSetOld (v1) vs purchasedSet (v2) | 兩套來源，邏輯一致 |
| 空結果 / 篩選後空結果文案 | 正確 |
| filter.isEmpty 與 hasActive | 正確 |

搜尋與 Filter 頁籤邏輯已完整檢查，無遺漏。
