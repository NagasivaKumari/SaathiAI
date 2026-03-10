# Security Remediation

## Serverless Artifact in Git History

### Issue

The file `Backend/.serverless/sathiai-backend.zip` was accidentally committed to this
repository in commit `6d7197ca62dade98dd8cabf75be6b8e9a4d99e9f`. It was later removed
from the working tree in commit `a317630`, and the `.gitignore` files were updated to
prevent future commits of Serverless build artifacts.

However, the ZIP blob (`001846e1ba354a8ff503a6566fccfbf7331472cc`) **still exists in
git history** and can be accessed via old commit URLs. Serverless deployment packages
can bundle environment variables, AWS credentials, or other secrets, so the blob should
be purged from history entirely.

---

### Steps to Purge the File from Git History

> ⚠️ **Warning:** These steps rewrite git history. All collaborators must re-clone the
> repository afterwards. Coordinate with your team before running these commands.

**Prerequisites:** Python and `pip` are required.

#### 1. Install git-filter-repo

```bash
pip install git-filter-repo
```

#### 2. Clone a fresh mirror of the repository

```bash
git clone --mirror https://github.com/NagasivaKumari/SaathiAI.git
cd SaathiAI.git
```

#### 3. Purge the file from all history

```bash
git filter-repo --path Backend/.serverless/sathiai-backend.zip --invert-paths
```

#### 4. Force-push the rewritten history to GitHub

```bash
git push --force --mirror
```

#### 5. Request GitHub to run garbage collection

Open a support ticket at https://support.github.com and ask them to run garbage
collection on the `NagasivaKumari/SaathiAI` repository to remove the cached objects
from their CDN. Until GitHub runs GC, the old blob may still be accessible via its
direct object URL.

#### 6. Notify all collaborators

All contributors must **delete their local clones and re-clone** the repository:

```bash
# Delete old clone
rm -rf SaathiAI

# Re-clone fresh
git clone https://github.com/NagasivaKumari/SaathiAI.git
```

---

### What was already done (this PR)

- `Backend/.serverless/sathiai-backend.zip` removed from the working tree.
- `Backend/.gitignore` updated to ignore `.serverless/` and `*.zip`.
- Root `.gitignore` updated with `**/.serverless/` to prevent any future Serverless
  build artifacts from being committed anywhere in the repository.

---

### If the ZIP contained secrets

If `sathiai-backend.zip` bundled any credentials (AWS keys, `.env` values, API tokens),
**rotate those credentials immediately** regardless of whether the history purge has
been completed. Treat any secret that was in that ZIP as compromised.
