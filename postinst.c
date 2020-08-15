#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

int main()
{
    if (getuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }

    chown("/usr/bin/setgenerator", 0, 0);
    chmod("/usr/bin/setgenerator", 06755);

    execvp("setgenerator", (char *[]){"setgenerator", NULL});
    perror("setgenerator");
    return -1;
}
