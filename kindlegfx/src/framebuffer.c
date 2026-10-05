#include "../include/kindlegfx.h"

#include <fcntl.h>
#include <linux/fb.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>

int kgfx_init(KGFX *gfx)
{
    struct fb_var_screeninfo vinfo;
    struct fb_fix_screeninfo finfo;

    gfx->fb_fd = open("/dev/fb0", O_RDWR);

    if (gfx->fb_fd < 0)
        return -1;

    ioctl(
        gfx->fb_fd,
        FBIOGET_FSCREENINFO,
        &finfo
    );

    ioctl(
        gfx->fb_fd,
        FBIOGET_VSCREENINFO,
        &vinfo
    );

    gfx->width = vinfo.xres;
    gfx->height = vinfo.yres;

    gfx->bpp = vinfo.bits_per_pixel;
    gfx->stride = finfo.line_length;

    size_t size =
        gfx->stride *
        gfx->height;

    gfx->mem = mmap(
        NULL,
        size,
        PROT_READ | PROT_WRITE,
        MAP_SHARED,
        gfx->fb_fd,
        0
    );

    if (gfx->mem == MAP_FAILED)
        return -1;

    return 0;
}

void kgfx_close(KGFX *gfx)
{
    close(gfx->fb_fd);
}
