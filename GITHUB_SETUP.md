# Step-by-step: Put this app on GitHub (first time)

Do these in order. You can run the commands in Terminal (macOS) from your project folder.

---

## 1. Open Terminal and go to your project folder

```bash
cd "/Users/yogi/Desktop/Family/Yogi Work/SwiftUI/Periodic Table"
```

(Use your real path if it’s different.)

---

## 2. Initialize a Git repository

```bash
git init
```

This creates a `.git` folder and makes the folder a Git repo. You only do this once per project.

---

## 3. See what will be committed

```bash
git status
```

You should see:
- **Untracked files** – everything that’s not ignored  
- Nothing listed for `xcuserdata/` or `build/` if `.gitignore` is working (those should be ignored).

---

## 4. Add all files (respecting .gitignore)

```bash
git add .
```

This stages all files that are **not** in `.gitignore` (so no `xcuserdata/`, no `build/`, etc.).

---

## 5. Make the first commit

```bash
git commit -m "Initial commit: Periodic Table SwiftUI app"
```

You’ve now made your first commit. Everything is saved in your **local** repo only.

---

## 6. Create a new repository on GitHub

1. Go to [https://github.com/new](https://github.com/new).
2. **Repository name:** e.g. `Periodic-Table` or `periodic-table-ios`.
3. **Description (optional):** e.g. “SwiftUI periodic table app for iOS”.
4. Choose **Public**.
5. **Do not** check “Add a README”, “Add .gitignore”, or “Choose a license” (you already have these or will add them locally).
6. Click **Create repository**.

---

## 7. Connect your local repo to GitHub

GitHub will show you commands. Use these (replace `YOUR_USERNAME` and `YOUR_REPO` with your GitHub username and repo name):

```bash
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

Example:

```bash
git remote add origin https://github.com/yogeshbhusara/Periodic-Table.git
```

Check it:

```bash
git remote -v
```

You should see `origin` pointing to your GitHub URL.

---

## 8. Rename branch to `main` (if needed)

GitHub’s default branch is usually `main`. If your branch is something else (e.g. `master`), rename it:

```bash
git branch -M main
```

---

## 9. Push your code to GitHub

```bash
git push -u origin main
```

- If GitHub asks to sign in, use your GitHub account (or a Personal Access Token if you use 2FA).
- After this, your code is on GitHub and the repo is public (if you chose Public).

---

## 10. Optional: Add a license

To add the MIT License:

1. On GitHub, open your repo.
2. Click **Add file** → **Create new file**.
3. Name the file: `LICENSE`.
4. Click **Choose a license template**, pick **MIT License**, set year and name, then commit.

Or create `LICENSE` locally, commit, and push:

```bash
# After creating the LICENSE file
git add LICENSE
git commit -m "Add MIT license"
git push
```

---

## Quick reference (after first time)

When you change code and want to push again:

```bash
git add .
git commit -m "Short description of what you changed"
git push
```

---

## If something goes wrong

- **“remote origin already exists”**  
  You already added `origin`. Use:  
  `git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git`

- **“failed to push” / authentication**  
  Sign in to GitHub (browser or CLI), or use a Personal Access Token as the password when Git asks.

- **Wrong files committed (e.g. xcuserdata)**  
  Add the correct entry to `.gitignore`, then run:  
  `git rm -r --cached "Periodic Table.xcodeproj/xcuserdata"`  
  Then:  
  `git add .`  
  `git commit -m "Stop tracking xcuserdata"`  
  `git push`
