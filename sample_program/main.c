#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char* argv[])
{
	pid_t pid = getpid();

	int fd = open("sample.txt", O_RDONLY);

	close(fd);

	return 0;
}
