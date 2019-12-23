#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

const char *tty_path = "/dev/ttyUSB1";

int main(int argc, char *argv[])
{
	int fd = open(tty_path, O_RDWR | O_NOCTTY);
	if (fd == -1)
		err(EXIT_FAILURE, "open: %s", tty_path);

	int bits = 0;
	if (ioctl(fd, TIOCMGET, &bits) == -1)
		err(EXIT_FAILURE, "ioctl: TIOCMGET");

	printf("CTS = %d, DCD = %d, DSR = %d\n",
						 (bits & TIOCM_CTS) != 0,
						 (bits & TIOCM_CD) != 0,
						 (bits & TIOCM_DSR) != 0);

	bits &= ~TIOCM_DTR;
	bits &= ~TIOCM_RTS;

	int i;
	for (i = 1; i < argc; i++) {
		if (strcasecmp(argv[i], "DTR") == 0)
			bits |= TIOCM_DTR;
		else if (strcasecmp(argv[i], "RTS") == 0)
			bits |= TIOCM_RTS;
		else if (strcasecmp(argv[i], "-DTR") == 0)
			bits &= ~TIOCM_DTR;
		else if (strcasecmp(argv[i], "-RTS") == 0)
			bits &= ~TIOCM_RTS;
		else
			errx(EXIT_FAILURE, "%s: invalid argument", argv[i]);
	}

	if (ioctl(fd, TIOCMSET, &bits) == -1)
		err(EXIT_FAILURE, "ioctl: TIOCMSET");

	if (close(fd) == -1)
		err(EXIT_FAILURE, "close");

	return EXIT_SUCCESS;
}
