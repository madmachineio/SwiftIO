/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */


#ifndef _SWIFT_ADC_H_
#define _SWIFT_ADC_H_

#include <sys/types.h>

/**
 * @brief Structure to receive adc information
 *
 * @param resolution the number of bits in the absolute value of the sample
 * @param ref_voltage adc refer volage
 */
struct swift_adc_info {
	ssize_t resolution;
	float ref_voltage;
};

typedef struct swift_adc_info swift_adc_info_t;

/**
 * @brief Open adc
 *
 * @param id ADC id
 * @return ADC handle, NULL is fail
 */
const void *swifthal_adc_open(int id);

/**
 * @brief Close adc
 *
 * @param adc ADC handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_close(const void *adc);

/**
 * @brief Read adc value
 *
 * @param adc ADC handle
 * @param sampla_buffer Pointer to storage for read data
 *
 * @retval Positive indicates the adc value.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_read(const void *adc, uint16_t *sample_buffer);

/**
 * @brief Get adc infomation
 *
 * @param adc ADC handle
 * @param info adc information, use @ref swift_adc_info
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_info_get(const void *adc, swift_adc_info_t *info);

/**
 * @brief Get ADC support device number
 *
 * The maximum number of devices, the id of swifthal_adc_open must be less than this value
 *
 * @return max device number
 */
int swifthal_adc_dev_number_get(void);

#endif /*_SWIFT_ADC_H_*/
