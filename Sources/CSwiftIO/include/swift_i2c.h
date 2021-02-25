/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Andy Liu,Frank Li
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_I2C_H_
#define _SWIFT_I2C_H_

#define SWIFT_I2C_SPEED_STANDARD (100 * 1000)
#define SWIFT_I2C_SPEED_FAST (400 * 1000)
#define SWIFT_I2C_SPEED_FAST_PLUS (1000 * 1000)

/** @brief I2C id number. */
enum swift_i2c_id {
	SWIFT_I2C_ID_0,
	SWIFT_I2C_ID_1,
	SWIFT_I2C_ID_NUM
};

/**
 * @brief Open a i2c
 *
 * @param id I2C id
 * @return I2C handle, NULL is fail
 */
void *swifthal_i2c_open(int id);

/**
 * @brief Close i2c
 *
 * @param i2c I2C handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2c_close(void *i2c);

/**
 * @brief Config i2c speed
 *
 * @param i2c I2C Handle
 * @param speed I2C speed
 * - SWIFT_I2C_SPEED_STANDARD = 100K
 * - SWIFT_I2C_SPEED_FAST = 400K
 * - SWIFT_I2C_SPEED_FAST_PLUS = 1M
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2c_config(void *i2c, unsigned int speed);

/**
 * @brief Write a set amount of data to an I2C device.
 *
 * This routine writes a set amount of data synchronously.
 *
 * @param i2c I2C handle
 * @param addr Address to the target I2C device for writing.
 * @param buf Memory pool from which the data is transferred.
 * @param length Number of bytes to write.
 *
 * @retval 0 If successful.
 * @retval -EIO General input / output error.
 */
int swifthal_i2c_write(void *i2c, unsigned char address, const unsigned char *buf, int length);

/**
 * @brief Read a set amount of data from an I2C device.
 *
 * This routine reads a set amount of data synchronously.
 *
 * @param i2c I2C handle.
 * @param addr Address of the I2C device being read.
 * @param buf Memory pool that stores the retrieved data.
 * @param length Number of bytes to read.
 *
 * @retval 0 If successful.
 * @retval -EIO General input / output error.
 */
int swifthal_i2c_read(void *i2c, unsigned char address, unsigned char *buf, int length);

/**
 * @brief Write then read data from an I2C device.
 *
 * This supports the common operation "this is what I want", "now give
 * it to me" transaction pair through a combined write-then-read bus
 * transaction.
 *
 * @param i2c I2C handle
 * @param addr Address of the I2C device
 * @param write_buf Pointer to the data to be written
 * @param num_write Number of bytes to write
 * @param read_buf Pointer to storage for read data
 * @param num_read Number of bytes to read
 *
 * @retval 0 if successful
 * @retval negative on error.
 */
int swifthal_i2c_write_read(void *i2c, unsigned char addr,
			    const void *write_buf, int num_write,
			    void *read_buf, int num_read);

#endif /* _SWIFT_I2C_H_ */

