# BlazeNeuro Linux - Quick Reference Card

## 🚀 Quick Start

```bash
# Clone and build
git clone https://github.com/MilkywayRides/Linux.git
cd Linux/BlazeNeuroLinux
sudo ./build.sh all

# Create USB
sudo ./build.sh usb /dev/sdX
```

## 📋 Build Commands

```bash
sudo ./build.sh all        # Complete build (2-3 hours)
sudo ./build.sh stage1     # Prepare environment
sudo ./build.sh stage2     # Build toolchain (60-90 min)
sudo ./build.sh stage3     # Build temp system (20-30 min)
sudo ./build.sh stage4     # Build final system (15-20 min)
sudo ./build.sh stage5     # Configure & kernel (30-45 min)
sudo ./build.sh clean      # Clean build directories
```

## 🐳 Docker Build (Recommended)

```bash
# Local Docker build
docker build -t blazeneuro-builder .
docker create --name blazeneuro blazeneuro-builder
docker cp blazeneuro:/blazeneuro-rootfs.tar.gz .
docker rm blazeneuro

# Test with verbose output
docker build --progress=plain -t blazeneuro-builder . 2>&1 | tee build.log
```

## 🔧 Troubleshooting

```bash
# Verify sources before building
bash scripts/verify-sources.sh

# Check build logs
tail -f logs/build.log

# Test individual stage
sudo ./build.sh stage2

# Clean and retry
sudo ./build.sh clean
sudo ./build.sh all
```

## 🌐 GitHub Actions

### Trigger Build
1. Push to main/develop branch
2. Or: Actions tab → Run workflow

### Download Artifacts
1. Go to completed workflow
2. Scroll to Artifacts section
3. Download `blazeneuro-system`

### Choose Workflow
- `build.yml` - Direct build (faster)
- `build-docker.yml` - Docker build (more reliable)

## 📁 Important Files

```
build.sh                          # Main build script
config/blazeneuro.conf            # Configuration
scripts/stages/0X-*.sh            # Build stages
scripts/verify-sources.sh         # Source verification
Dockerfile                        # Docker build
.github/workflows/build-docker.yml # GitHub Actions
```

## 🐛 Common Errors & Fixes

### Coreutils Build Fails
✅ **Fixed**: Config cache workarounds added

### MB_LEN_MAX Errors
✅ **Fixed**: Headers patched in glibc stage

### Parallel Build Failures
✅ **Fixed**: Auto-fallback to `make -j1`

### Source Not Found
```bash
bash scripts/verify-sources.sh
# If missing, download from GitHub Actions artifacts
```

## 📚 Documentation

- `README.md` - Complete guide
- `TROUBLESHOOTING.md` - Detailed solutions
- `GITHUB_ACTIONS_GUIDE.md` - Cloud build guide
- `FIXES_APPLIED.md` - All fixes documented

## 🎯 Best Practices

1. ✅ Use Docker build for CI/CD
2. ✅ Verify sources before building
3. ✅ Run stages individually when debugging
4. ✅ Keep build logs for troubleshooting
5. ✅ Test locally before pushing to GitHub

## 📊 Build Requirements

- **Disk Space**: 20GB+
- **RAM**: 4GB+
- **Time**: 2-3 hours
- **OS**: Linux (Ubuntu 20.04+, Debian 11+)

## 🔑 Key Versions

- Linux: 6.7.4
- GCC: 13.2.0
- Glibc: 2.39
- Binutils: 2.42

## 💡 Pro Tips

```bash
# Monitor build in real-time
tail -f logs/build.log

# Check disk space
df -h /mnt/lfs

# Parallel build control
export MAKEFLAGS="-j4"  # Use 4 cores

# Skip GUI build
sudo ./build.sh stage5  # Stop before stage6
```

## 🆘 Getting Help

1. Check `TROUBLESHOOTING.md`
2. Review `logs/build.log`
3. Test with Docker locally
4. Open GitHub issue with logs

## 🔗 Quick Links

- [GitHub Repo](https://github.com/MilkywayRides/Linux)
- [Linux From Scratch](https://www.linuxfromscratch.org/)
- [LFS Book](https://www.linuxfromscratch.org/lfs/view/stable/)

---

**Last Updated**: 2025-11-14
**Status**: All critical errors fixed ✅
