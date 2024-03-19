#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int chown(const char *pathname, uid_t owner, gid_t group) {
    typedef int (*orig_chown_type)(const char *pathname, uid_t owner, gid_t group);
    static orig_chown_type orig_chown = NULL;
    if (!orig_chown) {
        orig_chown = (orig_chown_type)dlsym(RTLD_NEXT, "chown");
    }
    if (orig_chown(pathname, owner, group) != 0) {
        errno = 0; // Ignore the error
    }
    return 0;
}

int fchown(int fd, uid_t owner, gid_t group) {
    typedef int (*orig_fchown_type)(int fd, uid_t owner, gid_t group);
    static orig_fchown_type orig_fchown;
    if (!orig_fchown) {
        orig_fchown = (orig_fchown_type)dlsym(RTLD_NEXT, "fchown");
    }
    if (orig_fchown(fd, owner, group) != 0) {
        errno = 0; // Ignore the error
    }
    return 0;
}

#include <fcntl.h>

int fchownat(int dirfd, const char *pathname, uid_t owner, gid_t group, int flags) {
    typedef int (*orig_fchownat_type)(int dirfd, const char *pathname, uid_t owner, gid_t group, int flags);
    static orig_fchownat_type orig_fchownat;
    if (!orig_fchownat) {
        orig_fchownat = (orig_fchownat_type)dlsym(RTLD_NEXT, "fchownat");
    }
    if (orig_fchownat(dirfd, pathname, owner, group, flags) != 0) {
        errno = 0; // Ignore the error
    }
    return 0;
}

