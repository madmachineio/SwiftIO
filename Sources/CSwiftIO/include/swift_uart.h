/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_UART_H_
#define _SWIFT_UART_H_

#include <stdint.h>
#include <sys/types.h>

/** @brief Parity modes */
enum swift_uart_parity {
	SWIFT_UART_PARITY_NONE,
	SWIFT_UART_PARITY_ODD,
	SWIFT_UART_PARITY_EVEN,
};

typedef enum swift_uart_parity swift_uart_parity_t;

/** @brief Number of stop bits. */
enum swift_uart_stop_bits {
	SWIFT_UART_STOP_BITS_1,
	SWIFT_UART_STOP_BITS_2,
};

typedef enum swift_uart_stop_bits swift_uart_stop_bits_t;

/** @brief Number of data bits. */
enum swift_uart_data_bits {
	SWIFT_UART_DATA_BITS_8,
};

typedef enum swift_uart_data_bits swift_uart_data_bits_t;


/**
 * @brief UART controller configuration structure
 *
 * @param baudrate  Baudrate setting in bps
 * @param parity    Parity bit, use @ref swift_uart_parity
 * @param stop_bits Stop bits, use @ref swift_uart_stop_bits
 * @param data_bits Data bits, use @ref swift_uart_data_bits
 * @param read_buf_len uart read buffer size
 */
struct swift_uart_cfg {
	ssize_t baudrate;
	swift_uart_parity_t parity;
	swift_uart_stop_bits_t stop_bits;
	swift_uart_data_bits_t data_bits;
	ssize_t read_buf_len;
};

typedef struct swift_uart_cfg swift_uart_cfg_t;


#endif /*_SWIFT_UART_H_*/
