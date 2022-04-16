source "[file dirname [info script]]/paths.tcl"

set PLATFORM_XSA [lindex ${argv} 0]

set platform_name "alchitry_platform"

# Use project dir as workspace.
# It's awful but Vitis makes anything else even more painful.
setws ${DESIGN_ROOT_DIR}

# Create platform project
# If the "-out" path is not normalized, "platform read" will fail later.
platform create \
   -name ${platform_name} \
   -hw "${PLATFORM_XSA}" \
   -proc "microblaze_0" -os "standalone"
platform active ${platform_name}

domain create \
   -name microblaze_standalone \
   -os standalone \
   -proc {microblaze_0}

importprojects .

platform generate
app switch -name main -platform alchitry_platform -domain microblaze_standalone
app config -name main build-config release
