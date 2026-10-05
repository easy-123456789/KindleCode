#include "../include/kindlegfx.h"

void kgfx_refresh(KGFX *gfx)
{
    (void)gfx;

    /*
        Kindle-specific refresh code
        goes here.

        Usually ioctl()
        with MXCFB_SEND_UPDATE
        on newer models.
    */
}
