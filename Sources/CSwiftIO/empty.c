#include <stdint.h>
#include <sys/types.h>


void *swifthal_get_specified_pointer(uint32_t address)
{
    return (void *)(address);
}