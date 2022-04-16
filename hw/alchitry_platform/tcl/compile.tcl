source -notrace "[file dirname [info script]]/paths.tcl"
source -notrace "${SCRIPT_DIR}/util.tcl"

set PROJECT_NAME    [lindex ${argv} 0]

open_project "[project_dir ${PROJECT_NAME}]/${PROJECT_NAME}.xpr"

proc is_run_complete {run_name} {
    set progress [get_property PROGRESS [get_runs ${run_name}]]
    return [ string equal ${progress} "100%" ]
}

proc do_run run_args {
    global NUM_CPUS
    set run_name [lindex ${run_args} 0]
    if {[is_run_complete ${run_name}]} {
        puts "INFO: ${run_name} already complete"
    } else {
        launch_runs {*}${run_args} -jobs ${NUM_CPUS}
        wait_on_run ${run_name}
        if {![is_run_complete ${run_name}]} {
            set msg "${run_name} failed!"
            error $msg "INFO: ${msg}" 100
        }
    }
}

# TODO: reset runs if needed
# reset_runs {synth_1 impl_1}

do_run {synth_1}
do_run {impl_1 -to_step write_bitstream}

close_project
