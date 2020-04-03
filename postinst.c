#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
    if (getuid() != 0) {
        setuid(0);
    }
    
    if (getuid() != 0) {
        printf("Can't set uid as 0.\n");
        return 1;
    }
    
    system("chown root:wheel /usr/bin/setgenerator");
    system("chmod 6755 /usr/bin/setgenerator");
    system("setgenerator");
    return 0;
}
