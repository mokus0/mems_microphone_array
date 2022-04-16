set SCRIPT_DIR [file dirname [info script]]
set DESIGN_ROOT_DIR ${SCRIPT_DIR}/..

set RTL_DIR ${DESIGN_ROOT_DIR}/rtl
set XDC_DIR ${DESIGN_ROOT_DIR}/xdc
set WORK_DIR ${DESIGN_ROOT_DIR}/work

proc project_dir {project_name} {
    global WORK_DIR
    return "${WORK_DIR}/${project_name}"
}
