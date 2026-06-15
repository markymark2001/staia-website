# AI Chat Privacy Policy Rewrite Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite Staia's privacy policy to more clearly cover AI chat, personalization, third-party processors, sensitive information, user controls, and regional privacy rights.

**Architecture:** Keep the site as a static Eleventy page and edit only the authored privacy page in `src/pages/privacy.html`. Preserve the existing clean URL permalink (`privacy/index.html`) and legal-page layout classes so the build continues to generate `/privacy/` and legacy redirects remain untouched.

**Tech Stack:** Eleventy 3, Nunjucks layouts, static HTML content, GitHub Pages artifact from `dist/`.

---

### Task 1: Research And Policy Shape

**Files:**
- Modify: `src/pages/privacy.html`
- Verify: `docs/workflows/runtime-evidence.md`

- [x] **Step 1: Read required repo context**

Read:

```bash
sed -n '1,260p' architecture.md
sed -n '1,260p' docs/workflows/writing-plans.md
sed -n '1,260p' docs/workflows/runtime-evidence.md
sed -n '1,280p' src/pages/privacy.html
```

Expected: confirm `src/pages/privacy.html` is the only authored privacy policy source and `dist/` is generated output.

- [x] **Step 2: Review current external policy patterns**

Use current sources from official or regulator pages:

```text
Character.AI privacy policy: https://policies.character.ai/privacy
Replika privacy policy: https://replika.com/legal/privacy/en
OpenAI privacy policy: https://openai.com/policies/row-privacy-policy/
xAI privacy policy and API/security docs: https://x.ai/legal/privacy-policy and https://docs.x.ai/developers/faq/security
EDPB Replika enforcement summary: https://www.edpb.europa.eu/news/national-news/2025/ai-italian-supervisory-authority-fines-company-behind-chatbot-replika_en
Eleventy permalink/front matter docs: https://www.11ty.dev/docs/permalinks/
```

Expected: preserve accurate public links and avoid copying legal text verbatim.

### Task 2: Rewrite The Privacy Policy

**Files:**
- Modify: `src/pages/privacy.html`

- [x] **Step 1: Replace policy body while preserving front matter and layout**

Edit `src/pages/privacy.html` so the page keeps:

```html
---
layout: layouts/base.njk
title: Privacy Policy - Staia
description: Privacy Policy for the Staia mobile app.
bodyClass: legal-page
permalink: privacy/index.html
---
<main class="legal-document wrap">
```

Expected: new body covers scope/controller, information collected, AI chat handling, sensitive information warnings, purposes, processors, sharing, retention, security, regional rights, children/age, international transfers, policy changes, and contact.

- [x] **Step 2: Keep the policy factual to Staia**

Use these known facts from the existing policy and terms:

```text
Company: MediaKey Solutions Inc.
App: Staia mobile application
Contact: support@staia.io
Minimum age: 17+
Core data: account, authentication, birth chart, chat messages, preferences, subscription status, device/diagnostic, analytics
Processors: Supabase, Railway, xAI/Grok, RevenueCat, Google Sign-In, Sign in with Apple, Firebase Cloud Messaging, Sentry, Statsig
```

Expected: no invented vendor, address, DPO, or contractual promise.

### Task 3: Verify Static Output And Browser Rendering

**Files:**
- Verify: `src/pages/privacy.html`
- Verify: generated `dist/privacy/index.html`

- [x] **Step 1: Inspect changed source**

Run:

```bash
sed -n '1,340p' src/pages/privacy.html
git diff --check
```

Expected: readable HTML, no trailing whitespace errors.

- [x] **Step 2: Build the site**

Run:

```bash
npm run build
```

Expected: Eleventy writes `dist/privacy/index.html` with no build errors.

- [x] **Step 3: Serve and verify the changed legal page**

Run:

```bash
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Open in Codex browser:

```text
http://localhost:8080/privacy/
```

Expected: privacy page renders, updated date and rewritten sections are visible, footer navigation still reaches Privacy Policy and Terms of Service, and browser console has no errors.

- [x] **Step 4: Check affected URLs**

Run:

```bash
curl -I http://127.0.0.1:8080/privacy/
curl -I http://127.0.0.1:8080/privacy.html
```

Expected: `/privacy/` returns `200 OK`; `/privacy.html` returns the static redirect page successfully.

### Task 4: Publish

**Files:**
- Commit: `src/pages/privacy.html`
- Commit: `docs/plans/2026-06-15-ai-chat-privacy-policy-rewrite.md`

- [x] **Step 1: Create a branch only if checkout is detached**

Run:

```bash
git status --short --branch
```

Expected: if output is `## HEAD (no branch)`, create one `codex/` branch at current HEAD before committing.

- [x] **Step 2: Commit and push**

Run:

```bash
git add src/pages/privacy.html docs/plans/2026-06-15-ai-chat-privacy-policy-rewrite.md
git commit -m "Update AI chat privacy policy"
git push -u origin HEAD
```

Expected: branch is pushed.

- [x] **Step 3: Open a non-draft PR into main for a non-main branch**

Before opening the PR, verify no merge conflicts with `main`. Then open a non-draft pull request into `main` summarizing the policy rewrite, research sources, and verification evidence.
