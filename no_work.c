#define _GNU_SOURCE
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

int main(){
    printf("%d\n", getpid());
    sleep(10);
    printf("starting...\n");
    char write_buffer[BLOCK_SIZE];
    char read_buffer[BLOCK_SIZE];
    memset(write_buffer, 'a', BLOCK_SIZE);
    memset(read_buffer, 0, BLOCK_SIZE);
    for(int i = 0; i < 1<<20; i++){
        int tmp = open("/tmp", O_RDWR | O_TMPFILE);
        write(tmp, write_buffer, BLOCK_SIZE);
        read(tmp, read_buffer, BLOCK_SIZE);
        close(tmp);
    }
    return 0;
}
