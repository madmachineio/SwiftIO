/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_COUNTER_H_
#define _SWIFT_COUNTER_H_

/**
 * @brief Open counter
 *
 * @param id Counter id
 * @param id Counter interrupt callback: param1-ticks, param2-user_data
 * @param id Counter interrupt callback user data
 *
 * @return Counter handle
 */
void *swifthal_counter_open(int id, void *user_data, void (*callback)(unsigned int, void *));

/**
 * @brief Close counter
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_close(void *counter);

/**
 * @brief Read count result
 *
 * @param counter Counter Handle
 *
 * @retval Positive indicates the count ticks.
 * @retval Negative errno code if failure.
 */
unsigned int swifthal_counter_read(void *counter);

/**
 * @brief Function to get counter frequency.
 *
 * @param counter Counter Handle
 *
 * @return Frequency of the counter in Hz, or zero if the counter does
 * not have a fixed frequency.
 */
unsigned int swifthal_counter_freq(void *counter);

/**
 * @brief Function to convert ticks to microseconds.
 *
 * @param counter Counter Handle
 * @param  ticks  Ticks.
 *
 * @return Converted microseconds.
 */
unsigned long long int swifthal_counter_ticks_to_us(void *counter, unsigned int ticks);

/**
 * @brief Function to convert microseconds to ticks.
 *
 * @param counter Counter Handle
 * @param  us     Microseconds.
 *
 * @return Converted ticks. Ticks will be saturated if exceed 32 bits.
 */
unsigned int swifthal_counter_us_to_ticks(void *counter, unsigned long long int us);



/**
 * @brief Start count from 0 tick
 *
 * Counting starts from 0, when ticks are reached, an interrupt
 * is generated and callback is called. But the counter will keep
 * counting until swifthal_counter_stop is called
 *
 * @param counter Counter handle
 * @param ticks  Ticks.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_start(void *counter, unsigned int ticks);

/**
 * @brief Stop count
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_stop(void *counter);



/**
 * @brief Get COUNTER support device number
 *
 * The maximum number of devices, the id of swifthal_counter_open must be less than this value
 *
 * @return max device number
 */
int swifthal_counter_dev_number_get(void);

#endif /*_SWIFT_COUNTER_H_*/
