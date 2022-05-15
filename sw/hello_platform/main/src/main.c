#include "xparameters.h"
#include "xil_printf.h"
#include "xgpio.h"
#include "xil_types.h"
#include "xaxidma.h"

#include <stdlib.h>

#define RECV_FREQ 4800000
#define RECV_CHUNK_BYTES (256 * 4)

// #define RECV_SEC 1
// #define RECV_BYTES (((RECV_SEC * RECV_FREQ / 8) / RECV_CHUNK_BYTES) * RECV_CHUNK_BYTES)
#define RECV_BYTES 4096

static void init_gpio(XGpio *leds, uint16_t device_id) {
    XGpio_Config *cfg_ptr = XGpio_LookupConfig(device_id);
    XGpio_CfgInitialize(leds, cfg_ptr, cfg_ptr->BaseAddress);
    XGpio_SetDataDirection(leds, 1, 0);
}

static void init_dma(XAxiDma * dma, uint16_t device_id) {
    XAxiDma_Config* cfg_ptr = XAxiDma_LookupConfig(device_id);
    int status = XAxiDma_CfgInitialize(dma, cfg_ptr);
    if (status != XST_SUCCESS) {
        xil_printf("Failed to initialize AXI DMA (status = %d)\r\n", status);
    }

    XAxiDma_Reset(dma);
    while (!XAxiDma_ResetIsDone(dma));
}

// TODO: adjust design so this can keep up with the microphones, it probably won't currently
static size_t dma_recv(XAxiDma * dma, uint8_t* buf, size_t bytes) {
    size_t total_transferred = 0;

    while (bytes >= RECV_CHUNK_BYTES) {
        uint32_t transfer_bytes = RECV_CHUNK_BYTES;

        int status = XAxiDma_SimpleTransfer(dma, (uintptr_t)buf, transfer_bytes, XAXIDMA_DEVICE_TO_DMA);
        if (status != XST_SUCCESS) {
            xil_printf("transfer failed (status = %d)\r\n", status);
            while(1);
        }

        while (XAxiDma_Busy(dma, XAXIDMA_DEVICE_TO_DMA));

        buf += transfer_bytes;
        bytes -= transfer_bytes;
        total_transferred += transfer_bytes;
    }

    return total_transferred;
}

int main() {
    xil_printf("Configuring HW...\r\n");

    XGpio leds;
    init_gpio(&leds, XPAR_AXI_GPIO_0_DEVICE_ID);

    XGpio_DiscreteWrite(&leds, 1, 0x01);
    xil_printf("Configuring DMA...\r\n");
    XAxiDma dma;
    init_dma(&dma, XPAR_PDM_1_BIT_SERIALIZED_AXI_DMA_0_DEVICE_ID);

    uint8_t * recv_buf = malloc(RECV_BYTES);
    if (recv_buf == NULL) {
        xil_printf("Failed to allocate %u bytes\r\n", RECV_BYTES);
        goto end;
    }

    XGpio_DiscreteWrite(&leds, 1, 0x02);
    xil_printf("Collecting %u bytes at %u Hz, %u byte chunks\r\n", RECV_BYTES, RECV_FREQ, RECV_CHUNK_BYTES);
    size_t bytes_read = dma_recv(&dma, recv_buf, RECV_BYTES);
    xil_printf("Done. Read %u bytes.\r\n", bytes_read);
    
    XGpio_DiscreteWrite(&leds, 1, 0x04);
    xil_printf("==== BEGIN AUDIO DATA ====\r\n");
    
    for (size_t i = 0; i < bytes_read; i++) {
        if ((i % 16) == 0) {
            xil_printf("%08x", i);
        }
        if ((i % 8) == 0) {
            xil_printf(" ");
        }
        xil_printf(" %02x", recv_buf[i]);

        if (((i+1) % 16) == 0) {
            xil_printf("\r\n");
        }
}

    xil_printf("==== END AUDIO DATA ====\r\n");

end:
    XGpio_DiscreteWrite(&leds, 1, 0xFF);
    while (1);
}
