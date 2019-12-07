#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
extern char **environ;

int run_cmd(char *cmd)
{
    pid_t pid;
    char *argv[] = {"sh", "-c", cmd, NULL};
    int status = posix_spawn(&pid, "/bin/sh", NULL, NULL, argv, environ);
    if (status == 0) {
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid");
        }
    }
    return status;
}

int usage()
{
    printf("Usage:\tsetgenerator [generator]\n");
    exit(2);
}

int main(int argc, char **argv)
{
    if (geteuid() != 0) {
        printf("Run this as root!\n");
        exit(1);
    }
    
    if (argc > 2) {
        usage();
    }
    
    if (argc == 2) {
        if (argv[1][0] != '0' || argv[1][1] != 'x' || strlen(argv[1]) != 18) {
            usage();
        } else {
            if (access("/var/mobile/Library/Preferences/com.michael.generator.plist", F_OK) == 0) {
                remove("/var/mobile/Library/Preferences/com.michael.generator.plist");
            }
            FILE *fp = fopen("/var/mobile/Library/Preferences/com.michael.generator.plist","a+");
            fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
            fprintf(fp, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
            fprintf(fp, "<plist version=\"1.0\">\n");
            fprintf(fp, "<dict>\n");
            fprintf(fp, "\t<key>generator</key>\n");
            fprintf(fp, "\t<string>%s</string>\n", argv[1]);
            fprintf(fp, "</dict>\n");
            fprintf(fp, "</plist>\n");
            fclose(fp);
        }
    }
    
    if (access("/var/mobile/Library/Preferences/com.michael.generator.plist", F_OK) == 0) {
        char generator[19];
        FILE *fp = fopen("/var/mobile/Library/Preferences/com.michael.generator.plist","r");
        for (int i=0; i<5; i++) {
            fscanf(fp, "%*[^\n]%*c");
        }
        fscanf(fp, "%*[^0]%[^<]", generator);
        fclose(fp);
        char command[32];
        sprintf(command, "dimentio %s", generator);
        run_cmd(command);
    }
    
    return 0;
}
