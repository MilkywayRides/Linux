CC = gcc
CFLAGS = -Wall -O2
GTK_FLAGS = `pkg-config --cflags --libs gtk+-3.0`
X11_FLAGS = -lX11

all: blazewm panel launcher

blazewm: compositor/blazewm.c
	$(CC) $(CFLAGS) -o blazewm compositor/blazewm.c $(X11_FLAGS)

panel: panel/panel.c
	$(CC) $(CFLAGS) -o panel panel/panel.c $(GTK_FLAGS)

launcher: launcher/launcher.c
	$(CC) $(CFLAGS) -o launcher launcher/launcher.c $(GTK_FLAGS)

install:
	install -m 755 blazewm /usr/local/bin/
	install -m 755 panel /usr/local/bin/blazeneuro-panel
	install -m 755 launcher /usr/local/bin/blazeneuro-launcher

clean:
	rm -f blazewm panel launcher
