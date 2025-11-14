# BlazeNeuro Build Troubleshooting Guide

## Common Build Errors and Solutions

### 1. Coreutils "No rule to make target 'all'" Error

**Problem**: Coreutils configure fails to generate proper Makefile during cross-compilation.

**Solution**: The build script now includes config cache workarounds:
```bash
cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
gl_cv_func_working_utimes=yes
EOF
./configure --cache-file=config.cache gl_cv_macro_MB_LEN_MAX_good=y
```

### 2. MB_LEN_MAX Errors

**Problem**: Headers complain about MB_LEN_MAX assumptions.

**Solution**: Fixed in glibc build stage by:
- Removing error directives from headers
- Adding proper MB_LEN_MAX definition to limits.h

### 3. PATH_MAX Undefined

**Problem**: Some packages fail because PATH_MAX is not defined.

**Solution**: Added to limits.h during glibc installation:
```c
#ifndef PATH_MAX
#define PATH_MAX 4096
#endif
```

### 4. Parallel Build Failures

**Problem**: Some packages fail with parallel make.

**Solution**: All build functions now include fallback:
```bash
make $MAKEFLAGS || make -j1
```

### 5. Source Files Not Found

**Problem**: Build script can't find source archives.

**Solution**: Sources are now searched in multiple locations:
- `$LFS/sources/`
- `${SOURCES_DIR}/`
- Both .tar.xz and .tar.gz extensions

## GitHub Actions Specific Issues

### Disk Space Issues

The workflow includes cleanup:
```bash
sudo rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc
```

### Download Failures

Multiple mirror URLs are provided with retry logic:
```bash
wget --continue --tries=5 --timeout=30
```

### Build Timeout

Increased to 360 minutes (6 hours) for complete builds.

## Using Docker Build (Recommended)

For more reliable builds, use the Docker-based workflow:

```bash
# Local build with Docker
docker build -t blazeneuro-builder .
docker create --name blazeneuro blazeneuro-builder
docker cp blazeneuro:/blazeneuro-rootfs.tar.gz .
```

Or use the GitHub Actions workflow: `.github/workflows/build-docker.yml`

## Debugging Tips

### Check Build Logs

```bash
cat logs/build.log
```

### Manual Stage Execution

```bash
sudo ./build.sh stage1  # Prepare
sudo ./build.sh stage2  # Toolchain
sudo ./build.sh stage3  # Temp system
```

### Verify Sources

```bash
cd sources
for f in *.tar.xz; do xz -t "$f" && echo "$f OK"; done
for f in *.tar.gz; do gzip -t "$f" && echo "$f OK"; done
```

### Check LFS Environment

```bash
ls -la /mnt/lfs/
ls -la /mnt/lfs/usr/include/
grep -r "MB_LEN_MAX" /mnt/lfs/usr/include/
```

## Best Practices

1. **Always use the Docker build** for CI/CD environments
2. **Run stages individually** when debugging
3. **Keep build logs** for troubleshooting
4. **Verify source integrity** before building
5. **Use config cache** for problematic packages

## Getting Help

If you encounter issues not covered here:

1. Check the build log in `logs/build.log`
2. Review the specific stage script in `scripts/stages/`
3. Consult the Linux From Scratch documentation
4. Open an issue with:
   - Full error message
   - Build log excerpt
   - System information (OS, available disk space, RAM)
