### 📄 Complete `QUICKSTART.md` Code

```markdown
# ⚡ Quick Start - 5 Minute Version

**Just want the commands?** Here they are. For detailed explanations, see the full step-by-step breakdown below.

---

## Prerequisites ✅

- [ ] [GitHub account](https://github.com/signup)
- [ ] [Git installed](https://git-scm.com/downloads)
- [ ] Text editor

**Check if Git is installed:**
```bash
git --version

```

---

## The Steps 🚀

### 1. Fork on GitHub

Click the **"Fork"** button at the top right of this repository page.

---

### 2. Clone Your Fork

```bash
git clone [https://github.com/YOUR-USERNAME/Good-first-Issue.git](https://github.com/YOUR-USERNAME/Good-first-Issue.git)
cd Good-first-Issue

```

*Replace YOUR-USERNAME with your GitHub username*

---

### 3. Create a Branch

```bash
git checkout -b add-your-name

```

---

### 4. Edit README.md

Open `README.md` and add your name to the Contributors section:

```markdown
- [Your Name](https://github.com/YOUR-USERNAME)

```

Save the file.

---

### 5. Commit & Push

```bash
git add README.md
git commit -m "Add [Your Name] to contributors"
git push origin add-your-name

```

---

### 6. Create Pull Request

1. Go to your repository on GitHub
2. Click **"Compare & pull request"**
3. Click **"Create pull request"**

---

## ✅ Done!

That's it! Wait for your PR to be reviewed and merged.

---

## 📚 Detailed Step-by-Step Guide

If you are new to open source, follow this deep-dive guide to learn the entire GitHub workflow that powers millions of open source projects worldwide.

---

### Step 1️⃣: Fork This Repository

**What is forking?**
Creating your own copy of this project in your GitHub account.

* Click the **"Fork"** button at the top-right of this page.
* Wait a few seconds while GitHub creates your copy.

✅ **Success Check:**
You should now be on `github.com/YOUR-USERNAME/Good-first-Issue`

---

### Step 2️⃣: Clone Your Fork

**What is cloning?**
Downloading the code to your computer so you can edit it.

* On **your forked repository**, click the green **"Code"** button.
* Copy the URL (should look like: `https://github.com/YOUR-USERNAME/Good-first-Issue.git`).
* Open your terminal/command prompt.
* Navigate to where you want to save the project (e.g., Desktop):

```bash
  cd Desktop

```

* Clone the repository:

```bash
  git clone [https://github.com/YOUR-USERNAME/Good-first-Issue.git](https://github.com/YOUR-USERNAME/Good-first-Issue.git)

```

* Navigate into the project folder:

```bash
  cd Good-first-Issue

```

✅ **Success Check:**
Run `ls` (Mac/Linux) or `dir` (Windows). You should see files like `README.md`.

---

### Step 3️⃣: Create a New Branch

**What is a branch?**
A separate version of the code where you can make changes safely.

```bash
git checkout -b add-your-name

```

💡 **Pro Tip:**
Replace `your-name` with your actual name (e.g., `add-john-doe`).

✅ **Success Check:**
You should see: `Switched to a new branch 'add-your-name'`

---

### Step 4️⃣: Add Your Name

* Open `README.md` in your text editor.
* Scroll down to the **"👥 Contributors"** section.
* Add your name following this **exact format**:

```markdown
  - [Aditya Singh Rathore](https://github.com/Adez017)

```

**Example:**

```markdown
- [John Doe](https://github.com/johndoe)

```

* Save the file (`Ctrl+S` or `Cmd+S`).

⚠️ **Common Mistakes to Avoid:**

* Don't forget the `-` at the start.
* Don't forget the square brackets `[]` around your name.
* Don't forget the parentheses `()` around your GitHub URL.
* Make sure the URL is YOUR GitHub profile (replace `YOUR-USERNAME`).

---

### Step 5️⃣: Commit Your Changes

**What is a commit?**
Saving your changes with a description of what you did.

* Check what you changed:

```bash
  git status

```

You should see `README.md` listed in red.

* Stage your changes:

```bash
  git add README.md

```

* Commit with a message:

```bash
  git commit -m "Add [Your Name] to contributors list"

```

**Example:**

```bash
git commit -m "Add John Doe to contributors list"

```

✅ **Success Check:**
You should see a message like `1 file changed, 1 insertion(+)`

---

### Step 6️⃣: Push to GitHub

**What is pushing?**
Uploading your changes from your computer back to GitHub.

```bash
git push origin add-your-name

```

*Remember to use the branch name you created in Step 3!*

✅ **Success Check:**
You should see `Branch 'add-your-name' set up to track remote branch`.

---

### Step 7️⃣: Create a Pull Request

**What is a Pull Request (PR)?**
Asking the project maintainer to review and accept your changes.

* Go to your forked repository on GitHub (`github.com/YOUR-USERNAME/Good-first-Issue`).
* You should see a yellow banner saying **"Compare & pull request"** - click it!
* Add a title: `Add [Your Name] to contributors`
* Add a description (optional but nice):

```text
  Hi! This is my first contribution to open source.
  I've added my name to the contributors list.
  Thank you for this beginner-friendly project! 🎉

```

* Click **"Create pull request"**.

✅ **Success Check:**
You should see your PR with a number (e.g., `#42`).

---

## 🆘 Stuck?

**Error: Git not found or command not recognized**
→ [Install Git](https://git-scm.com/downloads) and restart your terminal.

**Error: Permission denied when pushing**
→ Make sure you forked the repo and cloned YOUR fork, not the original repository path.

**Error: Merge conflict in Pull Request**
→ Someone else added their name in the same spot. Don't panic!

* Pull the latest changes: `git pull origin main`
* Fix the conflicts in `README.md` (remove the `<<<<`, `====`, `>>>>` markers).
* Add and commit: `git add README.md && git commit -m "Fix merge conflict"`
* Push again: `git push origin add-your-name`

**Need more help?**
→ Check `README.md` for detailed step-by-step instructions
→ See `FAQ.md` for common questions
→ [Open an issue](https://www.google.com/search?q=../../issues) if you're still stuck

---

## 🎯 What's Next?

* ⭐ Star this repository
* 📖 Read [RESOURCES.md](https://www.google.com/search?q=RESOURCES.md) to continue learning
* 🔍 Find your next contribution on [goodfirstissue.dev](https://goodfirstissue.dev)
* 🤝 Help review other people's PRs

---

## Beginner Tips

* Start with small contributions like fixing typos
* Always read `CONTRIBUTING.md` before making a PR
* Keep your commits clear and simple

---

**Congratulations on your first contribution!** 🎉

---

### 📝 What to replace in `README.md`:

Open `README.md`, delete the old long detailed tutorial section, and add this elegant clean link right under your welcome text box:

```markdown
---

## 🚀 Getting Started

Ready to make your very first open-source contribution? We have centralized all onboarding tutorials into a single, comprehensive workspace to keep our landing page clean and scannable!

### 👉 [Click Here to Open the Full Interactive Quickstart Guide!](QUICKSTART.md) 👈

---

