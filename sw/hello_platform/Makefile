WORK_DIR = work

XSCT = xsct
VITIS = vitis

PLATFORM_XSA = ../../hw/alchitry_platform/alchitry_platform.xsa

all: update sdk
update: clean init_workspace

clean:
	rm -Rf alchitry_platform .analytics .metadata .Xil xrc.log IDE.log vitis*.str RemoteSystemsTempFiles
	rm -f main.bit .init_workspace_done

.PHONY: init_workspace
init_workspace: .init_workspace_done
.init_workspace_done: $(PLATFORM_XSA)
	$(XSCT) tcl/init_workspace.tcl $(PLATFORM_XSA)
	touch .init_workspace_done

.PHONY: main.bit
main.bit: .init_workspace_done
	$(XSCT) tcl/compile.tcl
	updatemem -force \
		-meminfo "alchitry_platform/hw/alchitry_platform.mmi" \
		-bit "alchitry_platform/hw/alchitry_platform.bit" \
		-data "main/Release/main.elf" \
		-proc alchitry_platform_i/microblaze_0 \
		-out "main.bit" 

flash: main.bit
	alchitry-loader -r main.bit

sdk:
	$(VITIS) -workspace .
