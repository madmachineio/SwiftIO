/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Frank Li(lgl88911@163.com)
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_I2S_H_
#define _SWIFT_I2S_H_

/** @brief I2S work mode. */
enum swift_i2s_mode {
	SWIFT_I2S_MODE_PHILIPS,
	SWIFT_I2S_MODE_RIGHT_JUSTIFIED,
	SWIFT_I2S_MODE_LEFT_JUSTIFIED,
	SWIFT_I2S_MODE_NUM
};

typedef enum swift_i2s_mode swift_i2s_mode_t;

/** @brief I2S output channel type. */
enum swift_i2s_channel_type {
	SWIFT_I2S_CHAN_STEREO,
	SWIFT_I2S_CHAN_MONO_RIGHT,
	SWIFT_I2S_CHAN_MONO_LEFT
};

typedef enum swift_i2s_channel_type swift_i2s_channel_type_t;

/**
 * @brief UART controller configuration structure
 *
 * @param mode  I2s work mode, use @ref swift_i2s_mode
 * @param channel_type Output channel type, use @ref swift_i2s_channel_type
 * @param sample_bits Bits per sample
 * @param sample_rate Sample rate
 */
struct swift_i2s_cfg {
	swift_i2s_mode_t mode;                          /*!< refer I2SMode */
	swift_i2s_channel_type_t channel_type;          /*!< refer I2SChannel */
	int sample_bits;                                /*!< 8,16,24,32 */
	int sample_rate;                                /*!< 8K,11.025K,12K,16K,22.05K,24K,32K,44.1K,48K,96K,192K,384K */
};

typedef struct swift_i2s_cfg swift_i2s_cfg_t;

/**
 * @brief Open a i2s
 *
 * @param id		I2S ID, use @ref swift_i2s_id
 *
 * @return I2S handle
 */
void *swifthal_i2s_open(int id);

/**
 * @brief Get i2s handle by id
 *
 * If i2s id haven't be open, will retrun NULL
 *
 * @param id		I2S ID, use @ref swift_i2s_id
 *
 * @return I2S handle
 */
void *swifthal_i2s_handle_get(int id);

/**
 * @brief Get i2s id from handle
 *
 * If i2s handle is invalid, will retrun -1
 *
 * @param i2s		I2S Handle
 *
 * @return I2S ID
 */
int swifthal_i2s_id_get(void *i2s);


/**
 * @brief Close i2s
 *
 * @param i2s I2S handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_close(void *i2s);


/**
 * @brief Set i2s config information
 *
 * @param i2s I2S handle
 * @param tx_cfg	I2S send config, use @ref swift_i2s_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_tx_config_set(void *i2s, const swift_i2s_cfg_t *cfg);

/**
 * @brief Get i2s config information
 *
 * @param i2s I2S handle
 * @param tx_cfg	I2S send config, use @ref swift_i2s_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_tx_config_get(void *i2s, swift_i2s_cfg_t *cfg);

/**
 * @brief Set i2s send work status
 *
 * @param i2s I2S handle
 * @param enable	1 I2S send enable, 0 I2S send disable
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_tx_status_set(void *i2s, int enable);

/**
 * @brief Get i2s send work status
 *
 * @param i2s I2S handle
 *
 * @retval 0 If disable, 1 If enable.
 * @retval Negative errno code if failure.
 */

int swifthal_i2s_tx_status_get(void *i2s);

/**
 * @brief Get size of free space for writing
 *
 * @param i2s I2S handle
 *
 * @retval Positive indicates the size of free space for writing.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_tx_available_get(void *i2s);

/**
 * @brief Send given number of bytes from buffer through I2S.
 *
 * @param i2s I2S handle
 * @param buf buf Pointer to transmit buffer.
 * @param length Length of transmit buffer.
 * @param timeout Timeout in milliseconds.
 *
 * @retval Positive indicates the number of bytes actually read.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_write(void *i2s, const unsigned char *buf, int length, int timeout);

/**
 * @brief Terminate current transmit and clear the data waiting to be transferred.
 *
 * @param i2s I2S handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_write_terminate(void *i2s);

/**
 * @brief Set i2s config information
 *
 * @param i2s I2S handle
 * @param rx_cfg	I2S received config, use @ref swift_i2s_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_rx_config_set(void *i2s, const swift_i2s_cfg_t *cfg);

/**
 * @brief Get i2s config information
 *
 * @param i2s I2S handle
 * @param rx_cfg	I2S received config, use @ref swift_i2s_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_rx_config_get(void *i2s, swift_i2s_cfg_t *cfg);

/**
 * @brief Set i2s recevice work status
 *
 * @param i2s I2S handle
 * @param enable	1 I2S recevice enable, 0 I2S recevice disable
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_rx_status_set(void *i2s, int enable);

/**
 * @brief Get i2s recevice work status
 *
 * @param i2s I2S handle
 *
 * @retval 0 If disable, 1 If enable.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_rx_status_get(void *i2s);


/**
 * @brief Get size of remainder data for reading
 *
 * @param i2s I2S handle
 *
 * @retval Positive indicates the size of remainder data for reading.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_rx_available_get(void *i2s);

/**
 * @brief Receive given number of bytes from buffer through I2S.
 *
 * @param i2s I2S handle
 * @param buf buf Pointer to transmit buffer.
 * @param length Length of transmit buffer.
 * @param timeout Timeout in milliseconds.
 *
 * @retval Positive indicates the number of bytes actually read.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_read(void *i2s, unsigned char *buf, int length, int timeout);

/**
 * @brief Get I2S support device number
 *
 * The maximum number of devices, the id of swifthal_i2s_open must be less than this value
 *
 * @return max device number
 */
int swifthal_i2s_dev_number_get(void);

#endif /* _SWIFT_I2S_H_ */

