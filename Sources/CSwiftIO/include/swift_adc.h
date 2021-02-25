/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */


#ifndef _SWIFT_ADC_H_
#define _SWIFT_ADC_H_

/** @brief adc id number. */
enum swift_adc_id {
	SWIFT_ADC_ID_0,
	SWIFT_ADC_ID_1,
	SWIFT_ADC_ID_2,
	SWIFT_ADC_ID_3,
	SWIFT_ADC_ID_4,
	SWIFT_ADC_ID_5,
	SWIFT_ADC_ID_6,
	SWIFT_ADC_ID_7,
	SWIFT_ADC_ID_8,
	SWIFT_ADC_ID_9,
	SWIFT_ADC_ID_10,
	SWIFT_ADC_ID_11,
	SWIFT_ADC_ID_NUM,
};

/**
 * @brief Structure to receive adc information
 *
 * @param max_raw_value max raw value for adc value
 * @param ref_voltage adc refer volage
 */
struct swift_adc_info {
	int max_raw_value;
	float ref_voltage;
};

typedef struct swift_adc_info swift_adc_info_t;

/**
 * @brief Open adc
 *
 * @param id ADC id
 * @return ADC handle, NULL is fail
 */
void *swifthal_adc_open(int id);

/**
 * @brief Close adc
 *
 * @param adc ADC handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_close(void *adc);

/**
 * @brief Read adc value
 *
 * @param adc ADC handle
 *
 * @retval Positive indicates the adc value.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_read(void *adc);

/**
 * @brief Get adc infomation
 *
 * @param adc ADC handle
 * @param info adc information, use @ref swift_adc_info
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_info_get(void *adc, swift_adc_info_t *info);

#endif /*_SWIFT_ADC_H_*/
