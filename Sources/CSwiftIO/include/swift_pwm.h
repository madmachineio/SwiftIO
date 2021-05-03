/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_PWM_H_
#define _SWIFT_PWM_H_

/**
 * @brief Structure to receive pwm information
 *
 * @param max_frequency max pwm frequency
 * @param min_frequency min pwm frequency
 */
struct swift_pwm_info {
	int max_frequency;
	int min_frequency;
};

typedef struct swift_pwm_info swift_pwm_info_t;

/**
 * @brief Open a pwm
 *
 * @param id PWM id
 * @return PWM handle, NULL is fail
 */
void *swifthal_pwm_open(int id);

/**
 * @brief Close pwm
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_close(void *pwm);

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
int swifthal_pwm_set(void *pwm, int period, int pulse);

/**
 * @brief Suspend pwm output
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_suspend(void *pwm);

/**
 * @brief Resume pwm output
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_resume(void *pwm);

/**
 * @brief Get pwm infomation
 *
 * @param pwm PWM handle
 * @param info pwm information, use @ref swift_pwm_info
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_info_get(void *pwm, swift_pwm_info_t *info);

/**
 * @brief Get PWM support device number
 *
 * The maximum number of devices, the id of swifthal_pwm_open must be less than this value
 *
 * @return max device number
 */
int swifthal_pwm_dev_number_get(void);

#endif /*_SWIFT_PWM_H_*/
