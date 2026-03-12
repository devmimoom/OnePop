# OnePop Website — AI Search Optimization

此資料夾包含 OnePop 的官方網站，透過 GitHub Pages 免費託管。

## 目的

讓 AI 搜尋引擎（ChatGPT、Perplexity、Google AI Overview 等）能找到並推薦 OnePop。

## 檔案結構

```
website/
├── index.html        # 主頁（含 Schema.org JSON-LD、SEO meta、FAQ）
├── privacy.html      # 隱私權政策
├── terms.html        # 使用條款
├── 404.html          # 404 頁面
├── robots.txt        # 允許 AI 爬蟲存取
├── sitemap.xml       # 網站地圖
├── llms.txt          # LLM 友善摘要（新標準）
├── llms-full.txt     # LLM 完整資訊
├── icon.png          # Favicon / App Icon
├── og-image.png      # 社群分享預覽圖（建議替換為 1200x630px）
└── README.md         # 本文件
```

## 網站網址

部署後：**https://devmimoom.github.io/OnePop/**

## 部署步驟

### 1. 到 GitHub repo Settings 開啟 Pages

1. 前往 https://github.com/devmimoom/OnePop/settings/pages
2. **Source** 選擇 **GitHub Actions**
3. 儲存

### 2. Push 到 main 分支

```bash
# 確保在 main 分支（或合併 feature branch 到 main）
git checkout main
git merge feature/embed-rich-sections

# Push 到 onepop remote（不是 origin，origin 是 LuckBuilder）
git push onepop main
```

GitHub Actions 會自動偵測 `website/` 資料夾變更並部署。

### 3. 驗證

- 瀏覽 https://devmimoom.github.io/OnePop/ 確認網站上線
- 瀏覽 https://devmimoom.github.io/OnePop/llms.txt 確認 AI 可讀內容
- 瀏覽 https://devmimoom.github.io/OnePop/robots.txt 確認爬蟲規則

## 部署後必須做的事

### 1. 替換 App Store ID

App Store ID 已設定為 `id6758580702`。
App Store 連結：https://apps.apple.com/app/onepop/id6758580702

### 2. 替換 OG 分享圖

目前 `og-image.png` 暫時使用 App Icon。建議製作 **1200x630px** 的社群預覽圖替換。

### 3. 提交到搜尋引擎

- **Google Search Console**: https://search.google.com/search-console
  → 新增資源 → 輸入 `https://devmimoom.github.io/OnePop/`
  → 驗證 → 提交 sitemap: `https://devmimoom.github.io/OnePop/sitemap.xml`

- **Bing Webmaster Tools**: https://www.bing.com/webmasters
  → 新增網站 → 同上步驟
  → **ChatGPT 使用 Bing 搜尋，這步最關鍵！**

### 4. 更新 App Store Connect URL

將 App Store Connect 的以下欄位改為新網址：
- **Support URL** → `https://devmimoom.github.io/OnePop/#faq`
- **Privacy Policy URL** → `https://devmimoom.github.io/OnePop/privacy.html`
- **Marketing URL** → `https://devmimoom.github.io/OnePop/`

### 5. 額外提升 AI 可見度

- [ ] Product Hunt 上架
- [ ] Reddit (r/productivity, r/apps, r/iOSapps) 分享
- [ ] Medium / Dev.to 寫文章
- [ ] 聯繫 App 評測 blogger

## 注意事項

- `origin` remote 指向 LuckBuilder，**push 網站要用 `onepop` remote**
- 日後若購買自訂網域，需更新所有檔案中的 URL
