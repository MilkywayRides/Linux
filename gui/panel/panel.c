/* BlazePanel - Top status bar */
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <time.h>
#include <stdio.h>
#include <unistd.h>

#define PANEL_HEIGHT 30
#define BG_COLOR 0x001100
#define FG_COLOR 0x00FF00

int main() {
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) return 1;
    
    int screen = DefaultScreen(dpy);
    Window root = RootWindow(dpy, screen);
    int width = DisplayWidth(dpy, screen);
    
    Window panel = XCreateSimpleWindow(dpy, root, 0, 0, width, PANEL_HEIGHT, 0, BG_COLOR, BG_COLOR);
    XSelectInput(dpy, panel, ExposureMask);
    XMapWindow(dpy, panel);
    
    XftColor color;
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), DefaultColormap(dpy, screen), "#00FF00", &color);
    XftFont *font = XftFontOpenName(dpy, screen, "monospace:size=12");
    XftDraw *draw = XftDrawCreate(dpy, panel, DefaultVisual(dpy, screen), DefaultColormap(dpy, screen));
    
    while (1) {
        time_t t = time(NULL);
        struct tm *tm = localtime(&t);
        char buf[64];
        snprintf(buf, sizeof(buf), "BlazeNeuro | %02d:%02d:%02d", tm->tm_hour, tm->tm_min, tm->tm_sec);
        
        XClearWindow(dpy, panel);
        XftDrawStringUtf8(draw, &color, font, 10, 20, (XftChar8*)buf, strlen(buf));
        XFlush(dpy);
        sleep(1);
    }
}
