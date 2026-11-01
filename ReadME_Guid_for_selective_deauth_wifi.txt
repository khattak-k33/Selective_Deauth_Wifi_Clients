
---

### Upload to GitHub

```bash
cd ~/Documents/scripts
nano README.md          # paste the content above, save
git init                # skip if repo already exists
git add README.md selective_deauth_wifi.sh
git commit -m "Add selective_deauth_wifi.sh and README"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main