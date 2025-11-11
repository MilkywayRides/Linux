/* BlazeDesktop - Desktop with icons */
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <string.h>
#include <stdlib.h>

#define ICON_SIZE 64
#define BG_COLOR 0x000000
#define FG_COLOR 0x00FF00

typedef struct {
    char *name;
    char *path;
    int x, y;
    int is_folder;
} Icon;

Icon icons[] = {
    {"Home", "/home", 50, 50, 1},
    {"Documents", "/home/Documents", 50, 150, 1},
    {"Downloads", "/home/Downloads", 50, 250, 1},
    {"Terminal", "blazeterminal", 50, 350, 0},
    {NULL, NULL, 0, 0, 0}
};

Display *dpy;
Window win;
XftDraw *draw;
XftColor color;
XftFont *font;

void draw_icon(Icon *icon) {
    XSetForeground(dpy, DefaultGC(dpy, DefaultScreen(dpy)), FG_COLOR);
    XDrawRectangle(dpy, win, DefaultGC(dpy, DefaultScreen(dpy)), 
                   icon->x, icon->y, ICON_SIZE, ICON_SIZE);
    
    if (icon->is_folder) {
        XDrawLine(dpy, win, DefaultGC(dpy, DefaultScreen(dpy)),
                  icon->x + 10, icon->y + 20, icon->x + ICON_SIZE - 10, icon->y + 20);
    }
    
    XftDrawStringUtf8(draw, &color, font, icon->x, icon->y + ICON_SIZE + 15,
                      (XftChar8*)icon->name, strlen(icon->name));
}

void handle_click(int x, int y) {
    for (int i = 0; icons[i].name; i++) {
        if (x >= icons[i].x && x <= icons[i].x + ICON_SIZE &&
            y >= icons[i].y && y <= icons[i].y + ICON_SIZE) {
            char cmd[256];
            snprintf(cmd, sizeof(cmd), "%s &", icons[i].path);
            system(cmd);
        }
    }
}

int main() {
    dpy = XOpenDisplay(NULL);
    if (!dpy) return 1;
    
    int screen = DefaultScreen(dpy);
    Window root = RootWindow(dpy, screen);
    int width = DisplayWidth(dpy, screen);
    int height = DisplayHeight(dpy, screen);
    
    win = XCreateSimpleWindow(dpy, root, 0, 0, width, height, 0, BG_COLOR, BG_COLOR);
    XSelectInput(dpy, win, ExposureMask | ButtonPressMask);
    XMapWindow(dpy, win);
    XLowerWindow(dpy, win);
    
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), 
                      DefaultColormap(dpy, screen), "#00FF00", &color);
    font = XftFontOpenName(dpy, screen, "monospace:size=10");
    draw = XftDrawCreate(dpy, win, DefaultVisual(dpy, screen), 
                         DefaultColormap(dpy, screen));
    
    XEvent e;
    while (1) {
        XNextEvent(dpy, &e);
        if (e.type == Expose) {
            for (int i = 0; icons[i].name; i++) draw_icon(&icons[i]);
        } else if (e.type == ButtonPress) {
            handle_click(e.xbutton.x, e.xbutton.y);
        }
    }
}
