# Cloud Build with GitHub Actions

## Overview

BlazeNeuro automatically compiles in the cloud using GitHub Actions. No local build required.

## Setup

### 1. Push to GitHub
```bash
git init
git add .
git commit -m "Initial BlazeNeuro setup"
git remote add origin <your-repo-url>
git push -u origin main
```

### 2. Automatic Build
GitHub Actions automatically triggers on:
- Push to `main` or `develop` branch
- Pull requests to `main`
- Manual workflow dispatch

### 3. Monitor Build
1. Go to repository on GitHub
2. Click **Actions** tab
3. View running/completed builds

## Build Artifacts

After successful build, download:

### 1. Build Logs
- Contains complete compilation logs
- Useful for debugging
- Retention: 7 days

### 2. System Image
- `blazeneuro-rootfs.tar.gz`
- Complete root filesystem
- Retention: 30 days

## Extract System Image

```bash
# Download artifact from GitHub
unzip blazeneuro-system.zip

# Extract to USB or local directory
sudo mkdir -p /mnt/blazeneuro
sudo tar xzf blazeneuro-rootfs.tar.gz -C /mnt/blazeneuro
```

## Manual Trigger

### Via GitHub UI
1. Go to **Actions** tab
2. Select **Build BlazeNeuro** workflow
3. Click **Run workflow**
4. Select branch
5. Click **Run workflow** button

### Via GitHub CLI
```bash
gh workflow run build.yml
```

## Workflow Configuration

File: `.github/workflows/build.yml`

### Key Features
- ✅ Runs on Ubuntu latest
- ✅ 4-hour timeout
- ✅ Disk space optimization
- ✅ Parallel compilation
- ✅ Artifact upload
- ✅ Log preservation

### Customization

Edit `.github/workflows/build.yml`:

```yaml
# Change timeout
timeout-minutes: 240

# Change artifact retention
retention-days: 30

# Add custom steps
- name: Custom step
  run: echo "Custom command"
```

## Build Time

- **Average:** 90-120 minutes
- **Depends on:** GitHub runner load
- **Stages:** All 5 stages executed sequentially

## Troubleshooting

### Build Fails

1. Check **Actions** logs
2. Identify failed stage
3. Fix issue locally
4. Push changes
5. Automatic rebuild triggers

### Disk Space Issues

Workflow includes disk cleanup:
```yaml
- name: Free disk space
  run: |
    sudo rm -rf /usr/share/dotnet /usr/local/lib/android
```

### Timeout

Increase timeout in workflow:
```yaml
timeout-minutes: 360  # 6 hours
```

## Cost

GitHub Actions free tier:
- **Public repos:** Unlimited minutes
- **Private repos:** 2,000 minutes/month

BlazeNeuro build: ~120 minutes per build

## Security

- No secrets required for basic build
- Artifacts are private to repository
- Logs contain no sensitive data

## Advanced: Custom Runners

Use self-hosted runners for:
- Faster builds
- More disk space
- Custom hardware

```yaml
runs-on: self-hosted
```

## Comparison

| Method | Time | Cost | Disk | Control |
|--------|------|------|------|---------|
| Local | 2-4h | Free | 20GB | Full |
| GitHub Actions | 1.5-2h | Free* | Auto | Limited |
| Self-hosted | 1-2h | Hardware | Custom | Full |

*Free for public repos

## Next Steps

- Monitor builds in Actions tab
- Download artifacts when complete
- Create USB from downloaded image
- Customize workflow for your needs
