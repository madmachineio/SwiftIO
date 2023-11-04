/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_TIMER_H_
#define _SWIFT_TIMER_H_

#include <stdint.h>
#include <sys/types.h>

/**
 * @brief Timer trigger type
 */
enum swift_timer_type {
	/** Only trigger once */
	SWIFT_TIMER_TYPE_ONESHOT,
	/** Periodic trigger */
	SWIFT_TIMER_TYPE_PERIOD,
};

typedef enum swift_timer_type swift_timer_type_t;

/**
 * @brief Open a timer
 *
 * @return void*	Timer handle,NULL if not found or cannot be used.
 */
void *swifthal_timer_open();

/**
 * @brief Close a timer
 *
 * @param timer Timer handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_close(void *timer);

/**
 * @brief Start timer
 *
 * @param timer Timer handle
 * @param type		Trigger type of timer.
 * @param period	Timer period.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_start(void *timer, swift_timer_type_t type, ssize_t period);

/**
 * @brief Stop timer
 *
 * @param timer Timer handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_stop(void *timer);

/**
 * @brief Add callback for timer expire
 *
 * @param timer		Timer handle
 * @param param		callback param
 * @param callback	Function to invoke each time the timer expires.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_add_callback(void *timer, const void *param, void (*callback)(const void *));

/**
 * @brief Read timer status.
 *
 * This routine reads the timer's status, which indicates the number of times
 * it has expired since its status was last read.
 *
 * Calling this routine resets the timer's status to zero.
 *
 * @param timer Timer handle
 *
 * @return Timer status.
 */
uint32_t swifthal_timer_status_get(void *timer);

/**
 * @brief Get time remaining before a timer next expires.
 *
 * This routine computes the (approximate) time remaining before a running timer
 * next expires. If the timer is not running, it returns zero.
 *
 * @param timer Timer handle
 *
 * @return Remaining time (in milliseconds).
 */
uint32_t swifthal_timer_remaining_get(void *timer);

#endif  /*_SWIFT_TIMER_H_*/
