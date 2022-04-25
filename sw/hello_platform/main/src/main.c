#include "xparameters.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xil_types.h"

#define LED_DELAY 10000000

uint32_t *ddr3 = (void*) 0x80000000;
unsigned const ddr3_words = 256 * 1024 * 1024 / sizeof(*ddr3);

int main() {
    XGpio_Config *cfg_ptr;
    XGpio led_device;

    xil_printf("Initializing DDR3");
    for (unsigned i = 0; i < ddr3_words; i++) {
        ddr3[i] = i;
        if ((i % (1024 * 1024 / sizeof(*ddr3))) == 0) xil_printf(".");
    }
    xil_printf("done.\r\n");

    cfg_ptr = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_CfgInitialize(&led_device, cfg_ptr, cfg_ptr->BaseAddress);

    XGpio_SetDataDirection(&led_device, 1, 0);

    uint32_t x = 0;
    while (1) {
        x++;

        xil_printf("Tick %u: %u\r\n", x, ddr3[x]);
        XGpio_DiscreteWrite(&led_device, 1, x);
        for (volatile int delay = 0; delay < LED_DELAY; delay++);
    }
}
