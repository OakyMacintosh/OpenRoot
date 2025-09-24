// rootd su implementation
#include <pwd.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

bool is_root_user();
int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <command> [args...]\n", argv[0]);
        return 1;
    }

    if (!is_root_user()) {
        fprintf(stderr, "Error: This command requires root privileges.\n");
        return 1;
    }

    // Execute the command with root privileges
    execvp(argv[1], &argv[1]);
    
    // If execvp returns, an error occurred
    perror("execvp failed");
    return 1;
}