/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_UART_H_
#define _SWIFT_UART_H_

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
	int baudrate;
	swift_uart_parity_t parity;
	swift_uart_stop_bits_t stop_bits;
	swift_uart_data_bits_t data_bits;
	int read_buf_len;
};

typedef struct swift_uart_cfg swift_uart_cfg_t;

/**
 * @brief Open a UART
 *
 * @param id		Uart ID, use @ref swift_uart_id
 * @param cfg		Uart config, use @ref swift_uart_cfg
 *
 * @return void*	Uart handle,NULL if not found or cannot be used.
 */
void *swifthal_uart_open(int id, const swift_uart_cfg_t *cfg);

/**
 * @brief Close a Uart
 *
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_close(void *uart);

/**
 * @brief Set uart baudrate
 *
 * @param uart 		Uart handle
 * @param baudrate 	Uart baudrate setting in bps
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_baudrate_set(void *uart, int baudrate);

/**
 * @brief Set uart parity
 *
 * @param uart 		Uart handle
 * @param parity 	Parity bit, use @ref swift_uart_parity
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_parity_set(void *uart, swift_uart_parity_t parity);

/**
 * @brief Set uart stop bits
 *
 * @param uart 		Uart handle
 * @param stop_bits	Stop bits, use @ref swift_uart_stop_bits
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_stop_bits_set(void *uart, swift_uart_stop_bits_t stop_bits);

/**
 * @brief Set uart data bits
 *
 * @param uart 		Uart handle
 * @param data_bits 	Data bits, use @ref swift_uart_data_bits
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_swift_uart_data_bits_set(void *uart, swift_uart_stop_bits_t data_bits);

/**
 * @brief Get uart config information
 *
 * @param uart	Uart handle
 * @param cfg	Uart config, use @ref swift_uart_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_config_get(void *uart, swift_uart_cfg_t *cfg);

/**
 * @brief Send one character through UART.
 *
 * @param uart	Uart handle
 * @param c	Character to transmit
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_char_put(void *uart, unsigned char c);

/**
 * @brief Receive on character to buffer through UART.
 *
 * @param uart 		UART handle
 * @param c 		Pointer to receive buffer
 * @param timeout	Timeout in milliseconds.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_char_get(void *uart, unsigned char *c, int timeout);

/**
 * @brief Send given number of bytes from buffer through UART.
 *
 * @param uart Uart Handle
 * @param buf Pointer to transmit buffer.
 * @param length Length of transmit buffer.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_write(void *uart, const unsigned char *buf, int length);

/**
 * @brief Recvice given number of bytes to buffer through UART.
 *
 * @param uart Uart Handle
 * @param buf Pointer to revice buffer.
 * @param length Length of recvice buffer.
 * @param timeout Timeout in milliseconds.
 *
 * @retval Positive indicates the number of bytes actually read.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_read(void *uart, unsigned char *buf, int length, int timeout);

/**
 * @brief Get data amount in read buffer
 *
 * @param uart Uart handle
 *
 * @return data amount
 */
int swifthal_uart_remainder_get(void *uart);

/**
 * @brief Clear read buffer of UART
 *
 * @param uart Uart handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_buffer_clear(void *uart);

/**
 * @brief Get UART support device number
 *
 * The maximum number of devices, the id of swifthal_uart_open must be less than this value
 *
 * @return max device number
 */
int swifthal_uart_dev_number_get(void);

#endif /*_SWIFT_UART_H_*/
