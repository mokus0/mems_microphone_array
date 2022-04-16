source -notrace "[file dirname [info script]]/paths.tcl"
source -notrace "${SCRIPT_DIR}/util.tcl"

set PROJECT_NAME    [lindex ${argv} 0]
set XSA_FILE        [lindex ${argv} 1]

open_project "[project_dir ${PROJECT_NAME}]/${PROJECT_NAME}.xpr"

write_hw_platform -fixed -include_bit -force -file ${XSA_FILE}

close_project
