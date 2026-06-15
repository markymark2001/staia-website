# Privacy Policy Staia Repo Fact Check Implementation Plan

> **For agentic workers:** Follow this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct the privacy policy and matching legal references so they reflect the actual Staia app/backend repository data flows.

**Architecture:** Keep the public legal website as static Eleventy HTML. Update only authored legal pages and this superseding plan; do not edit generated `dist/` output. Use the main app repo (`/Users/markvasilyev/staia`) as the source of truth for actual runtime vendors, chat provider routing, memory storage, account deletion behavior, and attribution.

**Tech Stack:** Eleventy 3 static website, authored HTML legal pages, Flutter/Python/Supabase app repo evidence, GitHub PR update.

---

### Task 1: Fact-Check Against Staia App Runtime

**Files:**
- Read: `/Users/markvasilyev/staia/architecture.md`
- Read: `/Users/markvasilyev/staia/docs/runtime-configuration.md`
- Read: `/Users/markvasilyev/staia/docs/chat-runtime.md`
- Read: `/Users/markvasilyev/staia/docs/memory-runtime.md`
- Read: `/Users/markvasilyev/staia/docs/account-deletion.md`
- Read: `/Users/markvasilyev/staia/docs/subscription-lifecycle.md`
- Read: `/Users/markvasilyev/staia/docs/notifications.md`
- Read: `/Users/markvasilyev/staia/docs/mobile-attribution.md`
- Read: `/Users/markvasilyev/staia/docs/media-storage.md`
- Read: `/Users/markvasilyev/staia/backend/app/infrastructure/config/model_configs.py`
- Read: `/Users/markvasilyev/staia/backend/app/infrastructure/openrouter_chat_model.py`
- Read: `/Users/markvasilyev/staia/backend/app/infrastructure/openrouter_context.py`
- Read: `/Users/markvasilyev/staia/backend/app/infrastructure/config/settings.py`
- Read: `/Users/markvasilyev/staia/backend/app/infrastructure/repositories/postgres_user_profile_repository.py`

- [x] **Step 1: Confirm runtime vendor facts**

Use:

```bash
rg -n "OpenRouter|xAI|Grok|RevenueCat|Statsig|Sentry|Mem0|Qdrant|Airbridge|LangSmith|R2" /Users/markvasilyev/staia/backend /Users/markvasilyev/staia/lib /Users/markvasilyev/staia/docs
```

Expected findings:

```text
Production chat provider key is OPENROUTER_API_KEY, not a direct xAI API key.
Selected chat model is deepseek-v4-flash through OpenRouter.
x-ai/grok-4.1-fast is available in config but not selected.
Mem0/Qdrant are required production memory configuration.
Airbridge is used for mobile attribution and referral deep links.
LangSmith tracing is configurable for LangGraph observability.
Cloudflare R2 is used for profile avatar uploads.
Account deletion tombstones public.users and deletes auth.users, preserving product/conversation history internally behind RLS.
```

- [x] **Step 2: Check current official provider docs**

Use current official docs:

```text
OpenRouter privacy: https://openrouter.ai/privacy
OpenRouter data collection: https://openrouter.ai/docs/guides/privacy/data-collection
OpenRouter provider logging: https://openrouter.ai/docs/guides/privacy/provider-logging
OpenRouter ZDR: https://openrouter.ai/docs/guides/features/zdr
Mem0 privacy: https://mem0.ai/privacy-policy
Qdrant privacy/DPA: https://qdrant.tech/legal/privacy-policy/ and https://cloud.qdrant.io/dpa
Airbridge privacy: https://www.airbridgeco.com/privacy
LangChain/LangSmith privacy: https://www.langchain.com/privacy-policy
```

Expected: use provider-specific links in the policy and avoid direct xAI-specific retention/training claims.

### Task 2: Correct Legal Copy

**Files:**
- Modify: `src/pages/privacy.html`
- Modify: `src/pages/terms.html`

- [x] **Step 1: Replace xAI-specific AI-provider language**

In `src/pages/privacy.html`, replace direct xAI/Grok statements with OpenRouter and downstream model-provider routing:

```html
<p>Staia uses OpenRouter as an AI model gateway for AI-powered astrological responses and related AI tasks. OpenRouter may route requests to underlying model providers based on our configured model and provider settings. To provide this feature, we may send the AI service your prompt, relevant conversation context, birth chart context, memory context, tool results, and related technical metadata.</p>
```

Expected: no direct statement that Staia uses xAI API as the production AI provider.

- [x] **Step 2: Add missing processors supported by app repo evidence**

In `src/pages/privacy.html`, add service-provider entries for:

```text
OpenRouter
Mem0
Qdrant
Airbridge
LangSmith
Cloudflare R2
```

Expected: provider list matches app repo architecture/runtime docs without inventing unsupported vendors.

- [x] **Step 3: Correct account deletion and retention wording**

In `src/pages/privacy.html`, replace wording implying account deletion removes chat history from active systems with:

```html
<p>When you delete your account in the App, Staia deactivates the account, deletes the Supabase authentication user, and marks the related app user record as deleted. Signing in again creates a new account. We may preserve product history, conversation history, memory, usage, subscription, and audit records internally where needed for service integrity, legal obligations, safety, fraud prevention, accounting, analytics, and debugging. Direct user access to tombstoned account data is blocked.</p>
```

Expected: policy matches the tombstone model in `/Users/markvasilyev/staia/docs/account-deletion.md`.

- [x] **Step 4: Align Terms third-party examples**

In `src/pages/terms.html`, replace the old example list:

```html
(Supabase, RevenueCat, Firebase, xAI, etc.)
```

with:

```html
(Supabase, OpenRouter, RevenueCat, Firebase, Statsig, Sentry, Airbridge, and related infrastructure providers)
```

Expected: Terms no longer names xAI as the example AI service and does not promise deletion behavior that conflicts with the Privacy Policy account-deletion language.

### Task 3: Verify Website

**Files:**
- Verify: `src/pages/privacy.html`
- Verify: `src/pages/terms.html`

- [x] **Step 1: Inspect and build**

Run:

```bash
sed -n '1,260p' src/pages/privacy.html
sed -n '250,285p' src/pages/terms.html
git diff --check
npm run build
```

Expected: legal copy is readable, no whitespace errors, and Eleventy writes `dist/privacy/index.html` and `dist/terms/index.html`.

- [x] **Step 2: Browser-check legal pages**

Run:

```bash
python3 -m http.server 8080 --bind 127.0.0.1 --directory dist
```

Open:

```text
http://127.0.0.1:8080/privacy/
http://127.0.0.1:8080/terms/
```

Expected: both pages render; privacy shows OpenRouter, Mem0, Qdrant, Airbridge, LangSmith, Cloudflare R2, and corrected account deletion wording; terms shows the corrected third-party examples; browser console has no errors.

- [x] **Step 3: HTTP checks**

Run:

```bash
curl -I http://127.0.0.1:8080/privacy/
curl -I http://127.0.0.1:8080/terms/
curl -I http://127.0.0.1:8080/privacy.html
curl -I http://127.0.0.1:8080/terms.html
```

Expected: all return `200 OK`.

### Task 4: Update Existing PR

**Files:**
- Commit: `src/pages/privacy.html`
- Commit: `src/pages/terms.html`
- Commit: `docs/plans/2026-06-15-privacy-policy-staia-repo-fact-check.md`

- [x] **Step 1: Stage, amend, and push**

Run:

```bash
git add src/pages/privacy.html src/pages/terms.html docs/plans/2026-06-15-privacy-policy-staia-repo-fact-check.md
git commit --amend --no-edit
git push --force-with-lease
```

Expected: existing PR branch updates with one coherent commit.

- [x] **Step 2: Verify PR checks**

Run:

```bash
gh pr view 15 --json url,isDraft,mergeable,mergeStateStatus,statusCheckRollup
gh pr checks 15 --watch --interval 10
```

Expected: PR remains non-draft and mergeable; build passes and deploy is skipped.
