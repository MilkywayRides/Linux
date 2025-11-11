CC = gcc
CFLAGS = -O2 -Wall
LDFLAGS = -lX11 -lXft -lutil

all: blazewm blazepanel blazeterminal blazelauncher blazedesktop blazedock

blazewm: wm/blazewm.c
	$(CC) $(CFLAGS) -o blazewm wm/blazewm.c $(LDFLAGS)

blazepanel: panel/panel.c
	$(CC) $(CFLAGS) -o blazepanel panel/panel.c $(LDFLAGS)

blazeterminal: terminal/terminal.c
	$(CC) $(CFLAGS) -o blazeterminal terminal/terminal.c $(LDFLAGS)

blazelauncher: launcher/launcher.c
	$(CC) $(CFLAGS) -o blazelauncher launcher/launcher.c $(LDFLAGS)

blazedesktop: desktop/desktop.c
	$(CC) $(CFLAGS) -o blazedesktop desktop/desktop.c $(LDFLAGS)

blazedock: dock/dock.c
	$(CC) $(CFLAGS) -o blazedock dock/dock.c $(LDFLAGS)

install:
	install -m 755 blazewm /usr/bin/
	install -m 755 blazepanel /usr/bin/
	install -m 755 blazeterminal /usr/bin/
	install -m 755 blazelauncher /usr/bin/
	install -m 755 blazedesktop /usr/bin/
	install -m 755 blazedock /usr/bin/

clean:
	rm -f blazewm blazepanel blazeterminal blazelauncher blazedesktop blazedock
