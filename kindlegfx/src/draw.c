#include "../include/kindlegfx.h"

void kgfx_pixel(
    KGFX *gfx,
    int x,
    int y,
    KColor color
)
{
    if (x < 0 || y < 0)
        return;

    if (x >= gfx->width)
        return;

    if (y >= gfx->height)
        return;

    int offset =
        y * gfx->stride +
        x;

    gfx->mem[offset] = color.r;
}

void kgfx_clear(
    KGFX *gfx,
    KColor color
)
{
    for (int y = 0; y < gfx->height; y++)
    {
        for (int x = 0; x < gfx->width; x++)
        {
            kgfx_pixel(
                gfx,
                x,
                y,
                color
            );
        }
    }
}

void kgfx_fill_rect(
    KGFX *gfx,
    int x,
    int y,
    int w,
    int h,
    KColor color
)
{
    for (int py = y; py < y + h; py++)
    {
        for (int px = x; px < x + w; px++)
        {
            kgfx_pixel(
                gfx,
                px,
                py,
                color
            );
        }
    }
}
