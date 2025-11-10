# Cloud Build Guide

## GitHub Actions (FREE - 2000 minutes/month)

### Setup:
1. Push code to GitHub (already done)
2. Go to: https://github.com/MilkywayRides/Linux/actions
3. Click "Build BlazeNeuro" workflow
4. Click "Run workflow" → "Run workflow"

### Download Result:
1. Wait ~2-3 hours for build to complete
2. Go to workflow run page
3. Download "blazeneuro-system" artifact (tar.gz)
4. Extract and create USB:
```bash
sudo tar -xzf blazeneuro-system.tar.gz -C /mnt/lfs
sudo ./build.sh usb /dev/sdb
```

## Alternative: Google Cloud Shell (FREE)

```bash
# Open: https://shell.cloud.google.com
git clone https://github.com/MilkywayRides/Linux.git
cd Linux
sudo ./build.sh all
tar -czf blazeneuro.tar.gz -C /mnt/lfs .
# Download via Cloud Shell menu
```

## Alternative: AWS EC2 Free Tier

```bash
# Launch t2.micro Ubuntu instance
ssh -i key.pem ubuntu@<instance-ip>
git clone https://github.com/MilkywayRides/Linux.git
cd Linux
sudo ./build.sh all
tar -czf blazeneuro.tar.gz -C /mnt/lfs .
scp -i key.pem ubuntu@<instance-ip>:~/Linux/blazeneuro.tar.gz .
```

## Recommended: GitHub Actions
- Completely free (2000 min/month)
- No setup required
- Automatic artifact download
- 6 hours timeout (enough for build)
