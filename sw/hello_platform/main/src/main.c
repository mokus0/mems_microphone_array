#include "xparameters.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xil_types.h"

#define LED_DELAY 10000000

int main() {
    XGpio_Config *cfg_ptr;
    XGpio led_device;

    xil_printf("Booted microblaze...\r\n");

    cfg_ptr = XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
    XGpio_CfgInitialize(&led_device, cfg_ptr, cfg_ptr->BaseAddress);

    XGpio_SetDataDirection(&led_device, 1, 0);

    uint32_t x = 0;
    while (1) {
        x++;

        xil_printf("Tick %u\r\n", x);
        XGpio_DiscreteWrite(&led_device, 1, x);
        for (volatile int delay = 0; delay < LED_DELAY; delay++);
    }
}
