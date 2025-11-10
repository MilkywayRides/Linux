#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdio.h>
#include <stdlib.h>

Display *display;
Window root;
int screen;

void handle_map_request(XMapRequestEvent *e) {
    XSetWindowBorderWidth(display, e->window, 2);
    XSetWindowBorder(display, e->window, 0x00FF00);
    XMapWindow(display, e->window);
}

void handle_configure_request(XConfigureRequestEvent *e) {
    XWindowChanges wc;
    wc.x = e->x;
    wc.y = e->y;
    wc.width = e->width;
    wc.height = e->height;
    wc.border_width = 2;
    XConfigureWindow(display, e->window, e->value_mask, &wc);
}

int main() {
    display = XOpenDisplay(NULL);
    if (!display) return 1;
    
    screen = DefaultScreen(display);
    root = RootWindow(display, screen);
    
    XSelectInput(display, root, SubstructureRedirectMask | SubstructureNotifyMask);
    XSetWindowBackground(display, root, 0x001400);
    XClearWindow(display, root);
    
    XEvent event;
    while (1) {
        XNextEvent(display, &event);
        if (event.type == MapRequest)
            handle_map_request(&event.xmaprequest);
        else if (event.type == ConfigureRequest)
            handle_configure_request(&event.xconfigurerequest);
    }
    
    XCloseDisplay(display);
    return 0;
}
