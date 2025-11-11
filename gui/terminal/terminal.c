/* BlazeTerminal - Simple terminal emulator */
#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <pty.h>
#include <unistd.h>
#include <string.h>

#define WIDTH 800
#define HEIGHT 600
#define BG_COLOR 0x000000
#define FG_COLOR 0x00FF00

int main() {
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) return 1;
    
    int screen = DefaultScreen(dpy);
    Window win = XCreateSimpleWindow(dpy, RootWindow(dpy, screen), 100, 100, WIDTH, HEIGHT, 2, FG_COLOR, BG_COLOR);
    XStoreName(dpy, win, "BlazeTerminal");
    XSelectInput(dpy, win, ExposureMask | KeyPressMask);
    XMapWindow(dpy, win);
    
    XftColor color;
    XftColorAllocName(dpy, DefaultVisual(dpy, screen), DefaultColormap(dpy, screen), "#00FF00", &color);
    XftFont *font = XftFontOpenName(dpy, screen, "monospace:size=12");
    XftDraw *draw = XftDrawCreate(dpy, win, DefaultVisual(dpy, screen), DefaultColormap(dpy, screen));
    
    int master, slave;
    char name[256];
    openpty(&master, &slave, name, NULL, NULL);
    
    if (fork() == 0) {
        close(master);
        dup2(slave, 0); dup2(slave, 1); dup2(slave, 2);
        execl("/bin/bash", "bash", NULL);
    }
    close(slave);
    
    char buf[4096], display[4096] = {0};
    int y = 20;
    
    while (1) {
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(master, &fds);
        FD_SET(ConnectionNumber(dpy), &fds);
        
        select(master + ConnectionNumber(dpy) + 1, &fds, NULL, NULL, NULL);
        
        if (FD_ISSET(master, &fds)) {
            int n = read(master, buf, sizeof(buf) - 1);
            if (n > 0) {
                buf[n] = 0;
                strncat(display, buf, sizeof(display) - strlen(display) - 1);
                XClearWindow(dpy, win);
                XftDrawStringUtf8(draw, &color, font, 10, y, (XftChar8*)display, strlen(display));
                XFlush(dpy);
            }
        }
        
        if (FD_ISSET(ConnectionNumber(dpy), &fds)) {
            XEvent e;
            XNextEvent(dpy, &e);
            if (e.type == KeyPress) {
                char c;
                KeySym ks;
                XLookupString(&e.xkey, &c, 1, &ks, NULL);
                write(master, &c, 1);
            }
        }
    }
}
