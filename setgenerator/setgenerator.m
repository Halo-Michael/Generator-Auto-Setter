#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
extern char **environ;

int run_cmd(const char *cmd)
{
    pid_t pid;
    const char *argv[] = {"sh", "-c", cmd, NULL};
    int status = posix_spawn(&pid, "/bin/sh", NULL, NULL, (char* const*)argv, environ);
    if (status == 0) {
        if (waitpid(pid, &status, 0) == -1) {
            perror("waitpid");
        }
    }
    return status;
}

void usage()
{
    printf("Usage:\tsetgenerator [generator]\n");
}

bool modifyPlist(NSString *filename, void (^function)(id))
{
    NSData *data = [NSData dataWithContentsOfFile:filename];
    if (data == nil) {
        return false;
    }
    NSPropertyListFormat format = 0;
    NSError *error = nil;
    id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];
    if (plist == nil) {
        return false;
    }
    if (function) {
        function(plist);
    }
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList:plist format:format options:0 error:&error];
    if (newData == nil) {
        return false;
    }
    if (![data isEqual:newData]) {
        if (![newData writeToFile:filename atomically:YES]) {
            return false;
        }
    }
    return true;
}

int main(int argc, char **argv)
{
    if (geteuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }
    
    if (argc > 2) {
        usage();
        return 2;
    }
    
    if (argc == 2) {
        if (argv[1][0] != '0' || argv[1][1] != 'x' || strlen(argv[1]) != 18) {
            usage();
            return 2;
        } else {
            if (access("/var/mobile/Library/Preferences/com.michael.generator.plist", F_OK) == 0) {
                remove("/var/mobile/Library/Preferences/com.michael.generator.plist");
            }
            FILE *fp = fopen("/var/mobile/Library/Preferences/com.michael.generator.plist","a+");
            fprintf(fp, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
            fprintf(fp, "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n");
            fprintf(fp, "<plist version=\"1.0\">\n");
            fprintf(fp, "<dict>\n");
            fprintf(fp, "</dict>\n");
            fprintf(fp, "</plist>\n");
            fclose(fp);
            modifyPlist(@"/var/mobile/Library/Preferences/com.michael.generator.plist", ^(id plist) {
                plist[@"generator"] = [NSString stringWithUTF8String:argv[1]];
            });
        }
    }
    
    if (access("/var/mobile/Library/Preferences/com.michael.generator.plist", F_OK) == 0) {
        NSString *const generatorPlist = @"/var/mobile/Library/Preferences/com.michael.generator.plist";
        NSDictionary *const generator = [NSDictionary dictionaryWithContentsOfFile:generatorPlist];
        char command[32];
        sprintf(command, "dimentio %s", [generator[@"generator"] UTF8String]);
        run_cmd(command);
    } else {
        run_cmd("dimentio 0x1111111111111111");
    }
    
    return 0;
}
