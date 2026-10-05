#ifndef KINDLEGFX_H
#define KINDLEGFX_H

#include <stdint.h>

typedef struct
{
    int fb_fd;

    uint8_t *mem;

    int width;
    int height;

    int stride;
    int bpp;

} KGFX;

typedef struct
{
    uint8_t r;
    uint8_t g;
    uint8_t b;
    uint8_t a;
} KColor;

/* framebuffer */

int kgfx_init(KGFX *gfx);
void kgfx_close(KGFX *gfx);

/* drawing */

void kgfx_pixel(
    KGFX *gfx,
    int x,
    int y,
    KColor color
);

void kgfx_clear(
    KGFX *gfx,
    KColor color
);

void kgfx_fill_rect(
    KGFX *gfx,
    int x,
    int y,
    int w,
    int h,
    KColor color
);

/* eink */

void kgfx_refresh(KGFX *gfx);

#endif
