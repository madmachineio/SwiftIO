/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_PLATFORM_H_
#define _SWIFT_PLATFORM_H_

#define SWIFT_NO_WAIT   0
#define SWIFT_FOREVER (-1)

/**
 * @brief Put the current thread to sleep.
 *
 * @param ms Desired duration of sleep in ms.
 */
void swifthal_ms_sleep(int ms);

/**
 * @brief Cause the current thread to busy wait.
 *
 * @param us Desired duration of wait in us.
 */
void swifthal_us_wait(unsigned int us);

/**
 * @brief Get system uptime.
 *
 * @return Current uptime in milliseconds.
 */
long long swifthal_uptime_get(void);

/**
 * @brief Read the hardware clock.
 *
 * @return Current hardware clock up-counter (in cycles).
 */
unsigned int swifthal_hwcycle_get(void);

/**
 * @brief Convert hardware cycles to nanoseconds
 *
 * @param cycles hardware cycle number
 * @return nanoseconds
 */
unsigned int swifthal_hwcycle_to_ns(unsigned int cycles);

/**
 * @brief Fill the destination buffer with random data values that should
 *
 * @param buf destination buffer to fill with random data.
 * @param length size of the destination buffer.
 */
// Move to Swift runtime
// void swiftHal_randomGet(unsigned char *buf, int length);

#endif /*_SWIFT_PLATFORM_H_*/
