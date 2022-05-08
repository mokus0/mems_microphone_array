WORK_DIR = work
REPORTS_DIR = $(WORK_DIR)/reports
FPGA_PART = xc7a35tftg256-1
PROJECT_NAME = alchitry_platform

VIVADO = vivado

_default: alchitry_platform.xsa

.PHONY: clean
clean:
	rm -Rf work .*_done

.PHONY: setup
setup: .setup_done
.setup_done: tcl/setup.tcl tcl/paths.tcl
	mkdir -p $(WORK_DIR) $(REPORTS_DIR)
	$(VIVADO) -mode batch -source tcl/setup.tcl \
		-jou $(REPORTS_DIR)/setup.jou \
		-log $(REPORTS_DIR)/setup.log \
		-tclargs "$(PROJECT_NAME)" "$(FPGA_PART)"
	touch .setup_done

.PHONY: compile
compile: .compile_done
.compile_done: .setup_done tcl/compile.tcl tcl/paths.tcl tcl/util.tcl
	mkdir -p $(WORK_DIR) $(REPORTS_DIR)
	$(VIVADO) -mode batch -source tcl/compile.tcl \
		-jou $(REPORTS_DIR)/compile.jou \
		-log $(REPORTS_DIR)/compile.log \
		-tclargs "$(PROJECT_NAME)"
	touch .compile_done

alchitry_platform.xsa: .compile_done tcl/export_platform.tcl tcl/paths.tcl tcl/util.tcl
	$(VIVADO) -mode batch -source tcl/export_platform.tcl \
		-jou $(REPORTS_DIR)/export_platform.jou \
		-log $(REPORTS_DIR)/export_platform.log \
		-tclargs "$(PROJECT_NAME)" "$$(pwd)/$@"
