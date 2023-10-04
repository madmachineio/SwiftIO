/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_PWM_H_
#define _SWIFT_PWM_H_

#include <stdint.h>
#include <sys/types.h>

/**
 * @brief Structure to receive pwm information
 *
 * @param max_frequency max pwm frequency
 * @param min_frequency min pwm frequency
 */
struct swift_pwm_info {
	ssize_t max_frequency;
	ssize_t min_frequency;
};

typedef struct swift_pwm_info swift_pwm_info_t;

/**
 * @brief Open a pwm
 *
 * @param id PWM id
 * @return PWM handle, NULL is fail
 */
const void *swifthal_pwm_open(int id);

/**
 * @brief Close pwm
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_close(const void *pwm);

/**
 * @brief Set pwm paramater
 *
 * @param pwm PWM handle
 * @param period PWM period
 * @param pulse PWM high level pulse width
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_set(const void *pwm, ssize_t period, ssize_t pulse);

/**
 * @brief Suspend pwm output
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_suspend(const void *pwm);

/**
 * @brief Resume pwm output
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_resume(const void *pwm);

/**
 * @brief Get pwm infomation
 *
 * @param pwm PWM handle
 * @param info pwm information, use @ref swift_pwm_info
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_info_get(const void *pwm, swift_pwm_info_t *info);

/**
 * @brief Get PWM support device number
 *
 * The maximum number of devices, the id of swifthal_pwm_open must be less than this value
 *
 * @return max device number
 */
int swifthal_pwm_dev_number_get(void);

#endif /*_SWIFT_PWM_H_*/
