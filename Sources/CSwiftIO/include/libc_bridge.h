#ifndef _LIBC_BRIDGE_H_
#define _LIBC_BRIDGE_H_

#include <string.h>
#include <errno.h>

void *memalign(size_t, size_t);
void z_impl_sys_rand_get(void *dst, size_t);

#endif