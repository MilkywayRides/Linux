/* BlazeWM - Minimal Window Manager */
#include <X11/Xlib.h>
#include <stdlib.h>
#include <string.h>

#define BORDER_WIDTH 2
#define BORDER_COLOR 0x00FF00  // Green
#define BG_COLOR 0x000000      // Black

Display *dpy;
Window root;
XWindowAttributes attr;

void handle_key_press(XEvent *e) {
    if (e->xkey.keycode == 24) { // Q key
        XGrabKeyboard(dpy, root, True, GrabModeAsync, GrabModeAsync, CurrentTime);
        system("blazeterminal &");
        XUngrabKeyboard(dpy, CurrentTime);
    }
}

void handle_button_press(XEvent *e) {
    XGetWindowAttributes(dpy, e->xbutton.subwindow, &attr);
    XRaiseWindow(dpy, e->xbutton.subwindow);
}

int main() {
    XEvent ev;
    
    if (!(dpy = XOpenDisplay(NULL))) return 1;
    root = DefaultRootWindow(dpy);
    
    XSetWindowBackground(dpy, root, BG_COLOR);
    XClearWindow(dpy, root);
    
    XGrabKey(dpy, 24, Mod1Mask, root, True, GrabModeAsync, GrabModeAsync);
    XGrabButton(dpy, 1, Mod1Mask, root, True, ButtonPressMask, GrabModeAsync, GrabModeAsync, None, None);
    XSelectInput(dpy, root, SubstructureRedirectMask | SubstructureNotifyMask);
    
    for (;;) {
        XNextEvent(dpy, &ev);
        if (ev.type == KeyPress) handle_key_press(&ev);
        else if (ev.type == ButtonPress) handle_button_press(&ev);
        else if (ev.type == MapRequest) {
            XSetWindowBorderWidth(dpy, ev.xmaprequest.window, BORDER_WIDTH);
            XSetWindowBorder(dpy, ev.xmaprequest.window, BORDER_COLOR);
            XMapWindow(dpy, ev.xmaprequest.window);
        }
    }
}
