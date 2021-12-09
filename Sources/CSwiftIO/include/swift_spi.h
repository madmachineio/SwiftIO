/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_SPI_H_
#define _SWIFT_SPI_H_

#define SWIFT_SPI_MODE_CPOL             (1 << 1)
#define SWIFT_SPI_MODE_CPHA             (1 << 2)


/**
 * @brief Open a spi
 *
 * @param id SPI ID
 * @param speed	SPI communication speed
 * @param w_notify  Write async notify
 * @param r_notify  Read async notify
 * @return SPI handle, NULL is fail
 */
void *swifthal_spi_open(int id,
			int speed,
			unsigned short operation,
			void (*w_notify)(void *),
			void (*r_notify)(void *));

/**
 * @brief Close spi
 *
 * @param spi SPI handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_close(void *spi);

/**
 * @brief Config spi speed
 *
 * @param spi SPI Handle
 * @param speed SPI speed
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_config(void *spi, int speed, unsigned short operation);

/**
 * @brief Send given number of bytes from buffer through SPI.
 *
 * @param spi SPI Handle
 * @param buf Pointer to transmit buffer.
 * @param length Length of transmit buffer.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_write(void *spi, const unsigned char *buf, int length);

/**
 * @brief Recvice given number of bytes to buffer through SPI.
 *
 * @param uart SPI Handle
 * @param buf Pointer to revice buffer.
 * @param length Length of recvice buffer.
 *
 * @retval Positive indicates the number of bytes actually read.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_read(void *spi, unsigned char *buf, int length);

/**
 * @brief Asynchronous send given number of bytes from buffer through SPI.
 *
 * @param spi SPI Handle
 * @param buf Pointer to transmit buffer.
 * @param length Length of transmit buffer.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_async_write(void *spi, const unsigned char *buf, int length);

/**
 * @brief Asynchronous revice given number of bytes from buffer through SPI.
 *
 * @param spi SPI Handle
 * @param buf Pointer to revice buffer.
 * @param length Length of revice buffer.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_async_read(void *spi, unsigned char *buf, int length);

/**
 * @brief Get SPI support device number
 *
 * The maximum number of devices, the id of swifthal_spi_open must be less than this value
 *
 * @return max device number
 */
int swifthal_spi_dev_number_get(void);


#endif /* _SWIFT_SPI_H_ */

