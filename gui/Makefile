CC = gcc
CFLAGS = -O2 -Wall
LDFLAGS = -lX11 -lXft -lutil

all: blazewm blazepanel blazeterminal blazelauncher

blazewm: wm/blazewm.c
	$(CC) $(CFLAGS) -o blazewm wm/blazewm.c $(LDFLAGS)

blazepanel: panel/panel.c
	$(CC) $(CFLAGS) -o blazepanel panel/panel.c $(LDFLAGS)

blazeterminal: terminal/terminal.c
	$(CC) $(CFLAGS) -o blazeterminal terminal/terminal.c $(LDFLAGS)

blazelauncher: launcher/launcher.c
	$(CC) $(CFLAGS) -o blazelauncher launcher/launcher.c $(LDFLAGS)

install:
	install -m 755 blazewm /usr/bin/
	install -m 755 blazepanel /usr/bin/
	install -m 755 blazeterminal /usr/bin/
	install -m 755 blazelauncher /usr/bin/

clean:
	rm -f blazewm blazepanel blazeterminal blazelauncher
