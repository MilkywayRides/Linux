/* BlazeDock - Bottom dock like macOS */
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <string.h>
#include <stdlib.h>

#define DOCK_HEIGHT 60
#define ICON_SIZE 48
#define ICON_PADDING 10
#define BG_COLOR 0x001100
#define FG_COLOR 0x00FF00

typedef struct {
    char *name;
    char *cmd;
} DockApp;

DockApp apps[] = {
    {"Terminal", "blazeterminal"},
    {"Files", "blazefm"},
    {"Launcher", "blazelauncher"},
    {"Settings", "blazesettings"},
    {NULL, NULL}
};

Display *dpy;
Window dock;
int num_apps = 0;

void draw_dock() {
    XClearWindow(dpy, dock);
    
    int screen = DefaultScreen(dpy);
    XftColor color;
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), 
                      DefaultColormap(dpy, screen), "#00FF00", &color);
    XftFont *font = XftFontOpenName(dpy, screen, "monospace:size=10");
    XftDraw *draw = XftDrawCreate(dpy, dock, DefaultVisual(dpy, screen), 
                                  DefaultColormap(dpy, screen));
    
    int x = ICON_PADDING;
    for (int i = 0; apps[i].name; i++) {
        XSetForeground(dpy, DefaultGC(dpy, screen), FG_COLOR);
        XDrawRectangle(dpy, dock, DefaultGC(dpy, screen), 
                       x, 5, ICON_SIZE, ICON_SIZE);
        
        XftDrawStringUtf8(draw, &color, font, x + 5, DOCK_HEIGHT - 5,
                          (XftChar8*)apps[i].name, strlen(apps[i].name));
        x += ICON_SIZE + ICON_PADDING;
    }
}

void handle_click(int x) {
    int pos = ICON_PADDING;
    for (int i = 0; apps[i].name; i++) {
        if (x >= pos && x <= pos + ICON_SIZE) {
            char cmd[256];
            snprintf(cmd, sizeof(cmd), "%s &", apps[i].cmd);
            system(cmd);
            return;
        }
        pos += ICON_SIZE + ICON_PADDING;
    }
}

int main() {
    dpy = XOpenDisplay(NULL);
    if (!dpy) return 1;
    
    int screen = DefaultScreen(dpy);
    Window root = RootWindow(dpy, screen);
    int width = DisplayWidth(dpy, screen);
    int height = DisplayHeight(dpy, screen);
    
    for (int i = 0; apps[i].name; i++) num_apps++;
    int dock_width = num_apps * (ICON_SIZE + ICON_PADDING) + ICON_PADDING;
    int dock_x = (width - dock_width) / 2;
    
    dock = XCreateSimpleWindow(dpy, root, dock_x, height - DOCK_HEIGHT - 10, 
                               dock_width, DOCK_HEIGHT, 2, FG_COLOR, BG_COLOR);
    XSelectInput(dpy, dock, ExposureMask | ButtonPressMask);
    XMapWindow(dpy, dock);
    
    XEvent e;
    while (1) {
        XNextEvent(dpy, &e);
        if (e.type == Expose) {
            draw_dock();
        } else if (e.type == ButtonPress) {
            handle_click(e.xbutton.x);
        }
    }
}
