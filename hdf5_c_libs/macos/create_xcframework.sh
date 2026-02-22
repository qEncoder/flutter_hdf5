#!/usr/bin/env bash
#
# create_xcframework.sh
#
# Converts Libraries/libhdf5.dylib into Libraries/hdf5_c_libs.xcframework
# for use as a vendored_frameworks in the hdf5_c_libs CocoaPod.
#
# Usage:  cd hdf5_c_libs/macos && bash create_xcframework.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBRARIES_DIR="${SCRIPT_DIR}/Libraries"

# --- Configuration -----------------------------------------------------------
DYLIB_PATH="${LIBRARIES_DIR}/libhdf5.dylib"
FRAMEWORK_NAME="hdf5_c_libs"
BUNDLE_ID="com.qharbor.hdf5_c_libs"
VERSION="1.14.5"                      # adjust as needed
MIN_OS="10.14"
# -----------------------------------------------------------------------------

# Verify input exists
if [[ ! -f "${DYLIB_PATH}" ]]; then
  echo "ERROR: ${DYLIB_PATH} not found." >&2
  exit 1
fi

# Determine architectures from the fat binary
ARCHS=$(lipo -archs "${DYLIB_PATH}")
echo "Detected architectures: ${ARCHS}"

# Output paths
XCFW_DIR="${LIBRARIES_DIR}/${FRAMEWORK_NAME}.xcframework"
PLATFORM_DIR="${XCFW_DIR}/macos-$(echo "${ARCHS}" | tr ' ' '_')"
FW_DIR="${PLATFORM_DIR}/${FRAMEWORK_NAME}.framework"
VERSIONS_A="${FW_DIR}/Versions/A"
RESOURCES_DIR="${VERSIONS_A}/Resources"

# Clean previous output
if [[ -d "${XCFW_DIR}" ]]; then
  echo "Removing existing ${FRAMEWORK_NAME}.xcframework ..."
  rm -rf "${XCFW_DIR}"
fi

# --- 1. Create directory structure -------------------------------------------
echo "Creating framework directory structure ..."
mkdir -p "${VERSIONS_A}"
mkdir -p "${RESOURCES_DIR}"

# --- 2. Copy and rename the binary ------------------------------------------
echo "Copying dylib ..."
cp "${DYLIB_PATH}" "${VERSIONS_A}/${FRAMEWORK_NAME}"

# --- 3. Fix the install name -------------------------------------------------
echo "Fixing install name ..."
install_name_tool -id "@rpath/${FRAMEWORK_NAME}.framework/Versions/A/${FRAMEWORK_NAME}" \
  "${VERSIONS_A}/${FRAMEWORK_NAME}"

# --- 4. Create framework Info.plist ------------------------------------------
echo "Writing framework Info.plist ..."
cat > "${RESOURCES_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>${BUNDLE_ID}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${FRAMEWORK_NAME}</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>${VERSION}</string>
	<key>CFBundleVersion</key>
	<string>${VERSION}</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>MinimumOSVersion</key>
	<string>${MIN_OS}</string>
</dict>
</plist>
EOF

# --- 5. Create framework symlinks -------------------------------------------
echo "Creating framework symlinks ..."
ln -s A "${FW_DIR}/Versions/Current"
ln -s Versions/Current/${FRAMEWORK_NAME} "${FW_DIR}/${FRAMEWORK_NAME}"
ln -s Versions/Current/Resources         "${FW_DIR}/Resources"

# --- 6. Create xcframework Info.plist ----------------------------------------
echo "Writing xcframework Info.plist ..."

ARCH_ENTRIES=""
for arch in ${ARCHS}; do
  ARCH_ENTRIES="${ARCH_ENTRIES}			<string>${arch}</string>
"
done

cat > "${XCFW_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AvailableLibraries</key>
	<array>
		<dict>
			<key>BinaryPath</key>
			<string>${FRAMEWORK_NAME}.framework/Versions/A/${FRAMEWORK_NAME}</string>
			<key>LibraryIdentifier</key>
			<string>macos-$(echo "${ARCHS}" | tr ' ' '_')</string>
			<key>LibraryPath</key>
			<string>${FRAMEWORK_NAME}.framework</string>
			<key>SupportedArchitectures</key>
			<array>
${ARCH_ENTRIES}			</array>
			<key>SupportedPlatform</key>
			<string>macos</string>
		</dict>
	</array>
	<key>CFBundlePackageType</key>
	<string>XFWK</string>
	<key>XCFrameworkFormatVersion</key>
	<string>1.0</string>
</dict>
</plist>
EOF

# --- 7. Verify ---------------------------------------------------------------
echo ""
echo "=== Done! ==="
echo "Created: ${XCFW_DIR}"
echo ""
echo "Framework binary:"
otool -L "${VERSIONS_A}/${FRAMEWORK_NAME}" | head -5
echo ""
echo "Directory structure:"
find "${XCFW_DIR}" -maxdepth 5 | sed "s|${LIBRARIES_DIR}/||"
