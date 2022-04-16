source "[file dirname [info script]]/paths.tcl"

# Use project dir as workspace.
# It's awful but Vitis makes anything else even more painful.
setws ${DESIGN_ROOT_DIR}

app build "main"
