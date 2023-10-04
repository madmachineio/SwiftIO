/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_COUNTER_H_
#define _SWIFT_COUNTER_H_

#include <stdint.h>
#include <sys/types.h>

/**
 * @brief Open counter
 *
 * @param id Counter id
 *
 * @return Counter handle
 */
const void *swifthal_counter_open(int id);

/**
 * @brief Close counter
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_close(const void *counter);

/**
 * @brief Read count result
 *
 * @param counter Counter Handle
 * @param ticks  Pointer to where to store the current counter value
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_read(const void *counter, uint32_t *ticks);

/**
 * @brief Set callback to a counter
 *
 * @param counter Counter Handle
 * @param callback Counter interrupt callback user data
 * @param user_data Counter interrupt callback: param1-ticks, param2-user_data
 *
 * @return Negative errno code if failure.
 */
int swifthal_counter_add_callback(const void *counter, const void *user_data, void (*callback)(uint32_t, const void *));

/**
 * @brief Function to get counter frequency.
 *
 * @param counter Counter Handle
 *
 * @return Frequency of the counter in Hz, or zero if the counter does
 * not have a fixed frequency.
 */
uint32_t swifthal_counter_freq(const void *counter);

/**
 * @brief Function to convert ticks to microseconds.
 *
 * @param counter Counter Handle
 * @param  ticks  Ticks.
 *
 * @return Converted microseconds.
 */
uint64_t swifthal_counter_ticks_to_us(const void *counter, uint32_t ticks);

/**
 * @brief Function to convert microseconds to ticks.
 *
 * @param counter Counter Handle
 * @param  us     Microseconds.
 *
 * @return Converted ticks. Ticks will be saturated if exceed 32 bits.
 */
uint32_t swifthal_counter_us_to_ticks(const void *counter, uint64_t us);

/**
 * @brief Function to retrieve maximum top value that can be set.
 *
 * @param counter Counter Handle
 *
 * @return Max top value.
 */
uint32_t swifthal_counter_get_max_top_value(const void *counter);

/**
 * @brief Set a single shot alarm.
 *
 * After expiration alarm can be set again, disabling is not needed.
 * When alarm expiration handler is called, channel is considered available and
 * can be set again in that context.
 *
 * @param counter Counter handle
 * @param ticks  Ticks.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_set_channel_alarm(const void *counter, uint32_t ticks);

/**
 * @brief Cancel an alarm.
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_cancel_channel_alarm(const void *counter);

/**
 * @brief Start count from 0 tick
 *
 * Counting starts from 0, when ticks are reached, an interrupt
 * is generated and callback is called. But the counter will keep
 * counting until swifthal_counter_stop is called
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_start(const void *counter);

/**
 * @brief Stop count
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_stop(const void *counter);



/**
 * @brief Get COUNTER support device number
 *
 * The maximum number of devices, the id of swifthal_counter_open must be less than this value
 *
 * @return max device number
 */
int swifthal_counter_dev_number_get(void);

#endif /*_SWIFT_COUNTER_H_*/
