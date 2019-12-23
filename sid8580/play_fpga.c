#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>

const char *TTY_PATH = "/dev/ttyUSB1";

#define BUFFER_SIZE 512

typedef enum {
	FILLING,
	WAIT_FOR_DRAIN,
	END
} UploaderState;

int almostFull(int bits) {
	return bits & TIOCM_DSR;
}

int almostEmpty(int bits) {
	return bits & TIOCM_CTS;
}

int getBits(int fd) {
	int bits = 0;
	
	if (ioctl(fd, TIOCMGET, &bits) == -1)
		err(EXIT_FAILURE, "ioctl: TIOCMGET");
		
	return bits;
}

off_t getFileSize(int fd) {
	struct stat filestat = { 0 };

	fstat(fd, &filestat);
	
	return filestat.st_size;	
}

void delay() {
   struct timespec spec = {
       .tv_sec = 0L,
	   .tv_nsec = 50000000L /* 50 ms */
   };
   nanosleep(&spec, NULL);
}

off_t copy(int fileFd, int ttyFd, off_t count) {
	unsigned char buffer[BUFFER_SIZE] = { 0 };
	
	read(fileFd, &buffer, count);
	write(ttyFd, &buffer, count);
	
	return count;
}

void l(const char *str) {
	puts(str);
}

int main(int argc, char *argv[])
{
	// first parameter must be file to upload
	if (argc < 2) {
		err(EXIT_FAILURE, "missing file argument");
	}

	int fileFd = open(argv[1], O_RDONLY);
	if (fileFd == -1)
		err(EXIT_FAILURE, "open: %s", argv[1]);

	int ttyFd = open(TTY_PATH, O_RDWR | O_NOCTTY);
	if (ttyFd == -1)
		err(EXIT_FAILURE, "open: %s", TTY_PATH);

	off_t fileSize = getFileSize(fileFd);
	off_t offset = 0;
	UploaderState state = FILLING;

	l("start sending file");
	int bits = 0;
	while (state != END) {
		bits = getBits(ttyFd);
		
		switch (state) {
			case FILLING:
				if (almostFull(bits)) {
					l("fifo almost full");
					state = WAIT_FOR_DRAIN;
				} else if ((offset + BUFFER_SIZE) < fileSize) {
					l("sending full buffer");
					offset += copy(fileFd, ttyFd, BUFFER_SIZE);
				} else {
					l("sending last buffer");
					off_t count = BUFFER_SIZE - (fileSize - (offset + BUFFER_SIZE));
					offset += copy(fileFd, ttyFd, count);
					state = END;
				}
				break;
			case WAIT_FOR_DRAIN:
				l("waiting for drain");

				delay();
				if (almostEmpty(bits)) {
					state = FILLING;
				}
		}
	} 
	l("complete file sent");

	if (close(ttyFd) == -1)
		err(EXIT_FAILURE, "close");

	if (close(fileFd) == -1)
		err(EXIT_FAILURE, "close");

	return EXIT_SUCCESS;
}
