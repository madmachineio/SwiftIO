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

enum swift_i2s_dir {
	/** Receive data */
	SWIFT_I2S_DIR_RX,
	/** Transmit data */
	SWIFT_I2S_DIR_TX,
	/** Both receive and transmit data */
	SWIFT_I2S_DIR_BOTH,
	SWIFT_I2S_DIR_NUM
};

typedef enum swift_i2s_dir swift_i2s_dir_t;

enum i2s_trigger_cmd {
	/** @brief Start the transmission / reception of data.
	 *
	 * If SWIFT_I2S_DIR_TX is set some data has to be queued for transmission by
	 * the swift_i2s_write() function. This trigger can be used in READY state
	 * only and changes the interface state to RUNNING.
	 */
	SWIFT_I2S_TRIGGER_START,
	/** @brief Stop the transmission / reception of data.
	 *
	 * Stop the transmission / reception of data at the end of the current
	 * memory block. This trigger can be used in RUNNING state only and at
	 * first changes the interface state to STOPPING. When the current TX /
	 * RX block is transmitted / received the state is changed to READY.
	 * Subsequent START trigger will resume transmission / reception where
	 * it stopped.
	 */
	SWIFT_I2S_TRIGGER_STOP,
	/** @brief Empty the transmit queue.
	 *
	 * Send all data in the transmit queue and stop the transmission.
	 * If the trigger is applied to the RX queue it has the same effect as
	 * SWIFT_I2S_TRIGGER_STOP. This trigger can be used in RUNNING state only and
	 * at first changes the interface state to STOPPING. When all TX blocks
	 * are transmitted the state is changed to READY.
	 */
	SWIFT_I2S_TRIGGER_DRAIN,
	/** @brief Discard the transmit / receive queue.
	 *
	 * Stop the transmission / reception immediately and discard the
	 * contents of the respective queue. This trigger can be used in any
	 * state other than NOT_READY and changes the interface state to READY.
	 */
	SWIFT_I2S_TRIGGER_DROP,
	/** @brief Prepare the queues after underrun/overrun error has occurred.
	 *
	 * This trigger can be used in ERROR state only and changes the
	 * interface state to READY.
	 */
	SWIFT_I2S_TRIGGER_PREPARE,
};

typedef enum i2s_trigger_cmd i2s_trigger_cmd_t;

enum i2s_state {
	SWIFT_I2S_STATE_NOT_READY,
	/** The interface is ready to receive / transmit data. */
	SWIFT_I2S_STATE_READY,
	/** The interface is receiving / transmitting data. */
	SWIFT_I2S_STATE_RUNNING,
	/** The interface is draining its transmit queue. */
	SWIFT_I2S_STATE_STOPPING,
	/** TX buffer underrun or RX buffer overrun has occurred. */
	SWIFT_I2S_STATE_ERROR,
};

typedef enum i2s_state i2s_state_t;

#define SWIFT_I2S_DATA_ORDER_MSB        (0 << 3)
#define SWIFT_I2S_DATA_ORDER_LSB        (1 << 3)
#define SWIFT_I2S_BIT_CLK_INV           (1 << 4)
#define SWIFT_I2S_FRAME_CLK_INV         (1 << 5)

/** Run bit clock continuously */
#define SWIFT_I2S_BIT_CLK_CONT          (0 << 0)
/** Run bit clock when sending data only */
#define SWIFT_I2S_BIT_CLK_GATED         (1 << 0)
/** I2S driver is bit clock master */
#define SWIFT_I2S_BIT_CLK_MASTER        (0 << 1)
/** I2S driver is bit clock slave */
#define SWIFT_I2S_BIT_CLK_SLAVE         (1 << 1)
/** I2S driver is frame clock master */
#define SWIFT_I2S_FRAME_CLK_MASTER      (0 << 2)
/** I2S driver is frame clock slave */
#define SWIFT_I2S_FRAME_CLK_SLAVE       (1 << 2)

/**
 * @brief I2S controller configuration structure
 *
 * @param mode  I2s work mode, use @ref swift_i2s_mode
 * @param channels Number of words per frame
 * @param sample_bits Bits per sample
 * @param sample_rate Sample rate
 */
struct swift_i2s_cfg {
	swift_i2s_mode_t mode;                          /*!< refer I2SMode */
	int options;                                    /*!< Options for I2S */
	int channels;                                   /*!< Number of words per frame */
	int sample_bits;                                /*!< 8,16,24,32 */
	int sample_rate;                                /*!< 8K,11.025K,12K,16K,22.05K,24K,32K,44.1K,48K,96K,192K,384K */
	int timeout;                                    /*!< Number of words per frame */
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
 * @param dir Stream direction: RX, TX, or both, use @ref swift_i2s_dir
 * @param tx_cfg	I2S send config, use @ref swift_i2s_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_config_set(void *i2s, const swift_i2s_dir_t dir, const swift_i2s_cfg_t *cfg);

/**
 * @brief Get i2s config information
 *
 * @param i2s I2S handle
 * @param dir Stream direction: RX, TX, or both, use @ref swift_i2s_dir
 * @param tx_cfg	I2S send config, use @ref swift_i2s_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_config_get(void *i2s, const swift_i2s_dir_t dir, swift_i2s_cfg_t *cfg);

/**
 * @brief Set i2s send work status
 *
 * @param i2s I2S handle
 * @param enable	1 I2S send enable, 0 I2S send disable
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_trigger(void *i2s, const swift_i2s_dir_t dir, const i2s_trigger_cmd_t cmd);

/**
 * @brief Get i2s send work status
 *
 * @param i2s I2S handle
 *
 * @retval 0 If disable, 1 If enable.
 * @retval Negative errno code if failure.
 */

int swifthal_i2s_status_get(void *i2s, const swift_i2s_dir_t dir);


/**
 * @brief Send given number of bytes from buffer through I2S.
 *
 * @param i2s I2S handle
 * @param buf buf Pointer to transmit buffer.
 * @param length Length of transmit buffer.
 *
 * @retval Positive indicates the number of bytes actually read.
 * @retval Negative errno code if failure.
 */
int swifthal_i2s_write(void *i2s, const unsigned char *buf, int length);

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
int swifthal_i2s_read(void *i2s, unsigned char *buf, int length);

/**
 * @brief Get I2S support device number
 *
 * The maximum number of devices, the id of swifthal_i2s_open must be less than this value
 *
 * @return max device number
 */
int swifthal_i2s_dev_number_get(void);

#endif /* _SWIFT_I2S_H_ */

