# 💬 Frequently Asked Questions (FAQ)

Welcome to the FAQ! Here are answers to the most common questions new contributors ask when starting their open source journey.

<div align="center">

**[🏠 Home](README.md) | [⚡ Quick Start](QUICKSTART.md) | [🤝 Contributing](CONTRIBUTING.md) | [💬 FAQ](FAQ.md) | [📚 Resources](RESOURCES.md)**

</div>

---

## Table of Contents
- [🔄 Git & GitHub Workflow](#-git--github-workflow)
- [⚠️ Troubleshooting & Errors](#-troubleshooting--errors)
- [🤝 Contributions & PRs](#-contributions--prs)
- [🌱 Next Steps](#-next-steps)

---

## 🔄 Git & GitHub Workflow

### ❓ How do I keep my fork updated with the main repository?
If other people merge their Pull Requests while you are working, your fork can fall behind. To sync your fork with the latest changes:

1. Add the original repository as an `upstream` remote (you only need to do this once):
   ```bash
   git remote add upstream https://github.com/Adez017/Good-first-Issue.git
   ```
2. Fetch the latest changes from upstream:
   ```bash
   git fetch upstream
   ```
3. Checkout your main branch:
   ```bash
   git checkout main
   ```
4. Merge the upstream changes into your local main branch:
   ```bash
   git merge upstream/main
   ```
5. Push the updated main branch to your GitHub fork:
   ```bash
   git push origin main
   ```

---

## ⚠️ Troubleshooting & Errors

### ❓ I got a "Merge Conflict" in my Pull Request. What should I do?
A merge conflict happens when two people edit the same line of the same file, and Git doesn't know which version to keep. Don't worry, it's very easy to fix!

1. Make sure your local repository is updated (see the sync steps above).
2. Checkout your working branch:
   ```bash
   git checkout add-your-name
   ```
3. Merge the updated main branch into your working branch:
   ```bash
   git merge main
   ```
4. Open the conflicting file (`README.md` or `QUICKSTART.md`) in your text editor. Look for conflict markers:
   ```markdown
   <<<<<<< HEAD
   - [Your Name](https://github.com/YOUR-USERNAME)
   =======
   - [Someone Else](https://github.com/someone-else)
   >>>>>>> main
   ```
5. Edit the file to keep **both** names (make sure to delete the `<<<<<<<`, `=======`, and `>>>>>>>` markers).
6. Save the file, add, commit, and push:
   ```bash
   git add README.md
   git commit -m "Fix merge conflict"
   git push origin add-your-name
   ```

---

## 🤝 Contributions & PRs

### ❓ How long will it take for my Pull Request to be reviewed?
Our maintainers review contributions regularly. Reviews are typically completed within **24 to 48 hours**. We appreciate your patience! 

### ❓ Can I make multiple contributions to this repository?
**Yes, absolutely!** While the primary goal of this repository is to help you make your first contribution by adding your name, you are highly encouraged to help improve the project by:
- Fixing typos in the guides.
- Improving explanation clarity in `README.md` or `QUICKSTART.md`.
- Adding valuable educational resources to `RESOURCES.md`.

---

## 🌱 Next Steps

### ❓ How do I find more beginner-friendly projects to contribute to?
Once you have mastered the Git workflow in this project, you are ready to tackle real-world issues! Look for these labels on other repositories:
- `good first issue`
- `first-timers-only`
- `beginner-friendly`
- `help wanted`

You can also use tools like [goodfirstissue.dev](https://goodfirstissue.dev/) or [up-for-grabs.net](https://up-for-grabs.net/) to find curated open-source issues suited for beginners.

---

<div align="center">

**Still have questions?**
Feel free to open an [Issue](../../issues) or ask in the [Discussions](../../discussions) section. We're here to help you succeed! 🌟

</div>
