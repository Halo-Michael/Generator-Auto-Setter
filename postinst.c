#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
    if (getuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }
    
    system("chown root:wheel /usr/bin/setgenerator");
    system("chmod 6755 /usr/bin/setgenerator");
    system("setgenerator");
    return 0;
}
