# Using GitHub Actions to Build BlazeNeuro Linux

This guide explains how to use GitHub Actions for free cloud compilation of BlazeNeuro Linux, inspired by the BBR kernel compilation article.

## Why GitHub Actions?

- **Free**: 2000 minutes/month for private repos, unlimited for public
- **Powerful**: 2-core CPU, 7GB RAM, 14GB SSD
- **Automated**: Builds on every push
- **Artifacts**: Download compiled system as tarball

## Two Build Methods

### Method 1: Direct Build (Faster, Less Reliable)

Uses `build.yml` workflow:
- Builds directly on Ubuntu 22.04 runner
- Faster setup time
- May have dependency issues

**Pros**: Quick, simple
**Cons**: Less reproducible, harder to debug

### Method 2: Docker Build (Recommended)

Uses `build-docker.yml` workflow:
- Multi-stage Dockerfile
- Isolated build environment
- Reproducible builds
- Easy local testing

**Pros**: Reliable, reproducible, debuggable
**Cons**: Slightly longer build time

## Setup Instructions

### 1. Fork/Clone Repository

```bash
git clone https://github.com/yourusername/BlazeNeuroLinux.git
cd BlazeNeuroLinux
```

### 2. Enable GitHub Actions

1. Go to repository Settings
2. Navigate to Actions → General
3. Enable "Allow all actions and reusable workflows"
4. Save

### 3. Choose Workflow

**For Docker build (recommended):**
```bash
# Rename to activate
mv .github/workflows/build-docker.yml .github/workflows/build.yml.bak
mv .github/workflows/build-docker.yml .github/workflows/build.yml
```

**Or keep both** and manually select which to run.

### 4. Trigger Build

**Automatic**: Push to main/develop branch
```bash
git add .
git commit -m "Trigger build"
git push origin main
```

**Manual**: 
1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Choose branch
5. Click "Run workflow" button

## Monitoring Build

### View Progress

1. Go to Actions tab
2. Click on running workflow
3. Expand "Build complete system" step
4. Watch real-time logs

### Build Time

- Stage 1 (Prepare): ~2 minutes
- Stage 2 (Toolchain): ~60-90 minutes
- Stage 3 (Temp System): ~20-30 minutes
- Stage 4 (Final System): ~15-20 minutes
- Stage 5 (Configure): ~30-45 minutes

**Total**: ~2-3 hours

## Downloading Artifacts

### After Successful Build

1. Go to completed workflow run
2. Scroll to "Artifacts" section
3. Download:
   - `blazeneuro-system` - Root filesystem tarball (~500MB)
   - `build-logs` - Complete build logs

### Extract System

```bash
# Extract rootfs
mkdir blazeneuro-root
cd blazeneuro-root
tar xzf ../blazeneuro-rootfs.tar.gz

# Create bootable USB
sudo ../usb-installer/create-usb.sh /dev/sdX
```

## Local Docker Testing

Test the Docker build locally before pushing:

```bash
# Build image
docker build -t blazeneuro-builder .

# Check for errors
docker build --progress=plain -t blazeneuro-builder . 2>&1 | tee build.log

# Extract artifact
docker create --name blazeneuro blazeneuro-builder
docker cp blazeneuro:/blazeneuro-rootfs.tar.gz .
docker rm blazeneuro
```

## Workflow Configuration

### Adjust Timeout

Edit `.github/workflows/build-docker.yml`:

```yaml
jobs:
  build:
    timeout-minutes: 360  # 6 hours (increase if needed)
```

### Parallel Jobs

For faster builds, split stages:

```yaml
jobs:
  toolchain:
    runs-on: ubuntu-latest
    steps:
      - name: Build toolchain
        run: sudo ./build.sh stage2
      - uses: actions/upload-artifact@v4
        with:
          name: toolchain
          path: /mnt/lfs/tools/
  
  system:
    needs: toolchain
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: toolchain
          path: /mnt/lfs/tools/
      - name: Build system
        run: sudo ./build.sh stage3
```

## Troubleshooting

### Build Fails

**Check logs**:
1. Click on failed step
2. Expand error section
3. Download build-logs artifact

**Common fixes**:
```yaml
# Increase disk space
- name: Free disk space
  run: |
    sudo rm -rf /usr/share/dotnet /usr/local/lib/android
    sudo apt-get clean
    df -h

# Add more dependencies
- name: Install dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y build-essential python3 m4
```

### Timeout

Increase timeout or split into stages:
```yaml
timeout-minutes: 480  # 8 hours
```

### Out of Disk Space

```yaml
- name: Free space
  run: |
    sudo rm -rf /opt/ghc /usr/local/share/boost
    sudo docker system prune -af
```

## Best Practices

1. **Use Docker build** for production
2. **Test locally** before pushing
3. **Cache dependencies** for faster builds
4. **Split large builds** into stages
5. **Keep logs** for debugging
6. **Verify artifacts** after download

## Caching for Faster Builds

Add caching to workflow:

```yaml
- name: Cache sources
  uses: actions/cache@v3
  with:
    path: sources/
    key: sources-${{ hashFiles('config/packages.list') }}

- name: Cache toolchain
  uses: actions/cache@v3
  with:
    path: /mnt/lfs/tools/
    key: toolchain-${{ hashFiles('scripts/stages/02-toolchain.sh') }}
```

## Cost Considerations

### Free Tier Limits

- **Public repos**: Unlimited minutes
- **Private repos**: 2000 minutes/month
- **Storage**: 500MB artifacts (free)

### Optimization

- Use caching to reduce build time
- Only build on tagged releases
- Disable unnecessary stages

```yaml
on:
  push:
    tags:
      - 'v*'  # Only build on version tags
```

## Comparison with Local Build

| Aspect | Local Build | GitHub Actions |
|--------|-------------|----------------|
| Cost | Hardware + electricity | Free (public) |
| Time | 2-3 hours | 2-3 hours |
| Resources | Your machine | 2-core, 7GB RAM |
| Automation | Manual | Automatic |
| Artifacts | Local files | Downloadable |
| Reproducibility | Variable | Consistent |

## Advanced: Multi-Architecture

Build for multiple architectures:

```yaml
strategy:
  matrix:
    arch: [x86_64, aarch64]
    
steps:
  - name: Set up QEMU
    uses: docker/setup-qemu-action@v3
  
  - name: Build for ${{ matrix.arch }}
    run: |
      docker build --platform linux/${{ matrix.arch }} \
        -t blazeneuro-${{ matrix.arch }} .
```

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Original BBR Article](https://blog.example.com/bbr-github-actions)
- [Linux From Scratch](https://www.linuxfromscratch.org/)

## Support

For issues:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review workflow logs
3. Test Docker build locally
4. Open GitHub issue with logs
