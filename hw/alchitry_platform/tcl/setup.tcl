source -notrace "[file dirname [info script]]/paths.tcl"
source -notrace "${SCRIPT_DIR}/util.tcl"

set PROJECT_NAME    [lindex ${argv} 0]
set FPGA_PART       [lindex ${argv} 1]

create_project -force ${PROJECT_NAME} [project_dir ${PROJECT_NAME}] -part ${FPGA_PART}
set project [get_projects ${PROJECT_NAME}]

# Set project properties

# TODO add IP repos, if needed

# Import project sources
proc add_to_fileset {fileset files} {
    if {[llength $files] == 0 } {
        puts "INFO: no files for fileset ${fileset}"
    } else {
        add_files -fileset $fileset -norecurse $files
    }
}

add_to_fileset sources_1 [glob -nocomplain -directory ${RTL_DIR} -type f *.v]
add_to_fileset constrs_1 [glob -nocomplain -directory ${XDC_DIR} -type f *.xdc]
update_compile_order -fileset sources_1

# Generate block design and top-level wrapper
source -notrace "${SCRIPT_DIR}/bd_alchitry_platform.tcl"
set bd_name [get_bd_designs -of_objects [get_bd_cells /]]
set bd_file [get_files "$bd_name.bd"]
set wrapper_file [make_wrapper -files $bd_file -top -force]
import_files -fileset sources_1 -norecurse $wrapper_file
set_property "top" "${bd_name}_wrapper" [get_filesets sources_1]
update_compile_order -fileset sources_1

# TODO set up hierarchical synthesis and generate outputs
# TODO create and/or configure synth_1 run
# TODO create and/or configure impl_1 run

close_project
