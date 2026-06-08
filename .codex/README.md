# Staia Website Codex Local Environment

Codex reads `.codex/environments/environment.toml` to expose repo-local launch
actions in the desktop app.

## Actions

Use **Launch Website** to build the Eleventy site, serve `dist/` on the next
available local port starting at `STAIA_WEBSITE_PORT` or `8080`, and open the
site in Google Chrome.

The action delegates to:

```bash
./.codex/scripts/launch-website.sh
```
