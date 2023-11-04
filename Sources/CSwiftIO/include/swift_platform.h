/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_PLATFORM_H_
#define _SWIFT_PLATFORM_H_

#include <stdint.h>
#include <sys/types.h>

#define SWIFT_NO_WAIT   0
#define SWIFT_FOREVER (-1)

/**
 * @brief Put the current thread to sleep.
 *
 * @param ms Desired duration of sleep in ms.
 */
void swifthal_ms_sleep(ssize_t ms);

/**
 * @brief Cause the current thread to busy wait.
 *
 * @param us Desired duration of wait in us.
 */
void swifthal_us_wait(uint32_t us);

/**
 * @brief Get system uptime.
 *
 * @return Current uptime in milliseconds.
 */
int64_t swifthal_uptime_get(void);

/**
 * @brief Read the hardware clock.
 *
 * @return Current hardware clock up-counter (in cycles).
 */
uint32_t swifthal_hwcycle_get(void);

/**
 * @brief Convert hardware cycles to nanoseconds
 *
 * @param cycles hardware cycle number
 * @return nanoseconds
 */
uint32_t swifthal_hwcycle_to_ns(uint32_t cycles);

/**
 * @brief Fill the destination buffer with random data values that should
 *
 * @param buf destination buffer to fill with random data.
 * @param length size of the destination buffer.
 */
void swifthal_random_get(uint8_t *buf, ssize_t length);

#endif /*_SWIFT_PLATFORM_H_*/
