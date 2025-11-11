/* BlazeLauncher - Application launcher */
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <string.h>
#include <stdlib.h>

#define WIDTH 400
#define HEIGHT 300
#define BG_COLOR 0x001100
#define FG_COLOR 0x00FF00

typedef struct {
    char *name;
    char *cmd;
} App;

App apps[] = {
    {"Terminal", "blazeterminal"},
    {"File Manager", "blazefm"},
    {"Settings", "blazesettings"},
    {"About", "blazeabout"},
    {NULL, NULL}
};

int main() {
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) return 1;
    
    int screen = DefaultScreen(dpy);
    Window win = XCreateSimpleWindow(dpy, RootWindow(dpy, screen), 400, 200, WIDTH, HEIGHT, 2, FG_COLOR, BG_COLOR);
    XStoreName(dpy, win, "BlazeNeuro Launcher");
    XSelectInput(dpy, win, ExposureMask | ButtonPressMask);
    XMapWindow(dpy, win);
    
    XftColor color;
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), DefaultColormap(dpy, screen), "#00FF00", &color);
    XftFont *font = XftFontOpenName(dpy, screen, "monospace:size=14:bold");
    XftDraw *draw = XftDrawCreate(dpy, win, DefaultVisual(dpy, screen), DefaultColormap(dpy, screen));
    
    XEvent e;
    while (1) {
        XNextEvent(dpy, &e);
        if (e.type == Expose) {
            int y = 40;
            for (int i = 0; apps[i].name; i++) {
                XftDrawStringUtf8(draw, &color, font, 20, y, (XftChar8*)apps[i].name, strlen(apps[i].name));
                y += 40;
            }
        } else if (e.type == ButtonPress) {
            int idx = (e.xbutton.y - 20) / 40;
            if (idx >= 0 && apps[idx].name) {
                char cmd[256];
                snprintf(cmd, sizeof(cmd), "%s &", apps[idx].cmd);
                system(cmd);
            }
        }
    }
}
