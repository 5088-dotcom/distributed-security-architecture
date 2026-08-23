#!/bin/bash
# Complete APK Build and Test Script
# Builds the Android app and prepares for testing

set -e

echo "🚀 Distributed Security Architecture - APK Build & Test"
echo "========================================================="

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo -e "${YELLOW}[1/8]${NC} Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    exit 1
fi

if ! command -v pip &> /dev/null; then
    echo -e "${RED}✗ pip not found${NC}"
    exit 1
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ git not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"

# Install build tools
echo -e "${YELLOW}[2/8]${NC} Installing build tools..."
pip install --upgrade buildozer cython kivy
echo -e "${GREEN}✓ Build tools installed${NC}"

# Navigate to mobile directory
echo -e "${YELLOW}[3/8]${NC} Setting up mobile directory..."
cd mobile
echo -e "${GREEN}✓ In mobile directory${NC}"

# Create buildozer.spec if it doesn't exist
echo -e "${YELLOW}[4/8]${NC} Configuring buildozer..."
if [ ! -f buildozer.spec ]; then
    buildozer init
fi
echo -e "${GREEN}✓ buildozer.spec configured${NC}"

# Build APK (debug)
echo -e "${YELLOW}[5/8]${NC} Building APK (this may take 5-10 minutes)..."
echo "This will download Android SDK/NDK on first run..."
buildozer android debug
echo -e "${GREEN}✓ APK built successfully${NC}"

# Check if APK was created
echo -e "${YELLOW}[6/8]${NC} Verifying APK..."
if [ -f bin/distributed_security-0.1-debug.apk ]; then
    APK_SIZE=$(du -h bin/distributed_security-0.1-debug.apk | cut -f1)
    echo -e "${GREEN}✓ APK created: $APK_SIZE${NC}"
else
    echo -e "${RED}✗ APK not found in bin/${NC}"
    exit 1
fi

# Check for ADB
echo -e "${YELLOW}[7/8]${NC} Checking for connected Android device..."
if command -v adb &> /dev/null; then
    DEVICES=$(adb devices | grep -c "device$" || true)
    if [ "$DEVICES" -gt 0 ]; then
        echo -e "${GREEN}✓ Found $DEVICES Android device(s)${NC}"
        echo ""
        echo "Installing APK on device..."
        adb install -r bin/distributed_security-0.1-debug.apk
        echo -e "${GREEN}✓ APK installed${NC}"
        
        echo ""
        echo "Launching app..."
        adb shell am start -n com.security.distributed/.MainActivity
        echo -e "${GREEN}✓ App launched${NC}"
        
        echo ""
        echo "Monitoring logs (Ctrl+C to stop)..."
        echo -e "${YELLOW}[8/8]${NC} Real-time logs from device:"
        adb logcat -s "python" 2>/dev/null || adb logcat
    else
        echo -e "${YELLOW}⚠ No Android device connected${NC}"
        echo "To test, connect device and run: adb install -r bin/distributed_security-0.1-debug.apk"
        echo -e "${YELLOW}[8/8]${NC} Skipping device testing${NC}"
    fi
else
    echo -e "${YELLOW}⚠ ADB not found (Android SDK not in PATH)${NC}"
    echo "To test, manually install: bin/distributed_security-0.1-debug.apk"
    echo -e "${YELLOW}[8/8]${NC} Skipping device testing${NC}"
fi

echo ""
echo "=========================================================="
echo -e "${GREEN}✓ Build complete!${NC}"
echo ""
echo "APK Location: $(pwd)/bin/distributed_security-0.1-debug.apk"
echo ""
echo "Next steps:"
echo "1. Connect Android device via USB"
echo "2. Enable USB debugging on device"
echo "3. Run: adb install -r bin/distributed_security-0.1-debug.apk"
echo "4. Launch app from device home screen"
echo ""
echo "For release build:"
echo "  buildozer android release"
echo ""
echo "=========================================================="
