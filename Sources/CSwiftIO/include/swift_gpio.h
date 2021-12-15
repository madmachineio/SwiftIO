/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_GPIO_H_
#define _SWIFT_GPIO_H_

/** @brief GPIO direction, Input or output. */
enum swift_gpio_direction {
	SWIFT_GPIO_DIRECTION_OUT,
	SWIFT_GPIO_DIRECTION_IN,
};

typedef enum swift_gpio_direction swift_gpio_direction_t;

/** @brief GPIO internal electrical connection. */
enum swift_gpio_mode {
	SWIFT_GPIO_MODE_PULL_UP,
	SWIFT_GPIO_MODE_PULL_DOWN,
	SWIFT_GPIO_MODE_PULL_NONE,
	SWIFT_GPIO_MODE_OPEN_DRAIN,
};

typedef enum swift_gpio_mode swift_gpio_mode_t;

/** @brief GPIO interrupt trigger mode. */
enum swift_gpio_int_mode {
	SWIFT_GPIO_INT_MODE_RISING_EDGE,
	SWIFT_GPIO_INT_MODE_FALLING_EDGE,
	SWIFT_GPIO_INT_MODE_BOTH_EDGE,
	SWIFT_GPIO_INT_MODE_HIGH_LEVEL,
	SWIFT_GPIO_INT_MODE_LOW_LEVEL,
};

typedef enum swift_gpio_int_mode swift_gpio_int_mode_t;

/**
 * @brief Open gpio
 *
 * @param id GPIO id
 * @param direction GPIO direction, use @ref swift_gpio_direction
 * - SWIFT_GPIO_DIRECTION_OUT = GPIO be used to output
 * - SWIFT_GPIO_DIRECTION_IN = GPIO be used to input
 * @param io_mode GPIO internal electrical connection, use @ref swift_gpio_mode
 * - SWIFT_GPIO_MODE_PULL_UP = pull up, for input and output
 * - SWIFT_GPIO_MODE_PULL_DOWN = pull down, only for input
 * - SWIFT_GPIO_MODE_PULL_NONE = pull none, only for input
 * - SWIFT_GPIO_MODE_OPEN_DRAIN = open drain, only for output
 *
 * @return GPIO handle, NULL is fail
 */
void *swifthal_gpio_open(int id,
			 swift_gpio_direction_t direction,
			 swift_gpio_mode_t io_mode);

/**
 * @brief Close gpio
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_close(void *gpio);

/**
 * @brief Configure opened GPIO, change direction and mode
 *
 * @param gpio GPIO handle
 * @param direction GPIO direction, use @ref swift_gpio_direction
 * - SWIFT_GPIO_DIRECTION_OUT = GPIO be used to output
 * - SWIFT_GPIO_DIRECTION_IN = GPIO be used to input
 * @param io_mode GPIO internal electrical connection, use @ref swift_gpio_mode
 * - SWIFT_GPIO_MODE_PULL_UP = pull up, for input and output
 * - SWIFT_GPIO_MODE_PULL_DOWN = pull down, only for input
 * - SWIFT_GPIO_MODE_PULL_NONE = pull none, only for input
 * - SWIFT_GPIO_MODE_OPEN_DRAIN = open drain, only for output
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_config(void *gpio,
			 swift_gpio_direction_t direction,
			 swift_gpio_mode_t io_mode);

/**
 * @brief Set output GPIO level
 *
 * @param gpio GPIO handle
 * @param level gpio level
 * - 0 = low level
 * - 1 = hight level
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_set(void *gpio, int level);

/**
 * @brief Get input GPIO level
 *
 * @param gpio GPIO handle
 *
 * @retval 0 low level
 * @retval 1 high level
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_get(void *gpio);

/**
 * @brief Config input GPIO interrupt
 *
 * @param gpio GPIO handle
 * @param int_mode interrput trigger mode
 * - SWIFT_GPIO_INT_MODE_RISING_EDGE = rising edge trigger interrupt
 * - SWIFT_GPIO_INT_MODE_FALLING_EDGE = falling edge trigger interrupt
 * - SWIFT_GPIO_INT_MODE_BOTH_EDGE = rising or falling edge trigger interrupt
 * - SWIFT_GPIO_INT_MODE_HIGH_LEVEL = high level trigger interrupt
 * - SWIFT_GPIO_INT_MODE_LOW_LEVEL = low level trigger interrupt
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_config(void *gpio, swift_gpio_int_mode_t int_mode);

/**
 * @brief The installed callback will be called when the interrupt is generated
 *
 * @param gpio GPIO handle
 * @param callback interrupt callback
 * @param param callback paramater
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_callback_install(void *gpio, const void *param, void (*callback)(void *));

/**
 * @brief Uninstall interrupt callback
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_callback_uninstall(void *gpio);

/**
 * @brief Enable GPIO interrupt
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_enable(void *gpio);

/**
 * @brief Disable GPIO interrupt
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_disable(void *gpio);

/**
 * @brief Get GPIO support device number
 *
 * The maximum number of devices, the id of swifthal_gpio_open must be less than this value
 *
 * @return max device number
 */
int swifthal_gpio_dev_number_get(void);

#endif /* _SWIFT_GPIO_H_ */

