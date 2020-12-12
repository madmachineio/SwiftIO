

typedef struct {
	void *classPtr;
	void (*callback)(void *);
} CallbackWrapper;


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
int swifthal_adc_close(const void *adc);

/**
 * @brief Read adc value
 *
 * @param adc ADC handle
 *
 * @retval Positive indicates the adc value.
 * @retval Negative errno code if failure.
 */
int swifthal_adc_read(const void *adc);

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







#define SWIFT_I2C_SPEED_STANDARD (100 * 1000)
#define SWIFT_I2C_SPEED_FAST (400 * 1000)
#define SWIFT_I2C_SPEED_FAST_PLUS (1000 * 1000)


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
int swifthal_i2c_close(const void *i2c);

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
int swifthal_i2c_config(const void *i2c, unsigned int speed);

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
int swifthal_i2c_write(const void *i2c, unsigned char address, const unsigned char *buf, int length);

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
int swifthal_i2c_read(const void *i2c, unsigned char address, unsigned char *buf, int length);

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
int swifthal_i2c_write_read(const void *i2c, unsigned char addr,
			    const void *write_buf, int num_write,
			    void *read_buf, int num_read);



















#define SWIFT_NO_WAIT   0
#define SWIFT_FOREVER (-1)

/**
 * @brief Put the current thread to sleep.
 *
 * @param ms Desired duration of sleep in ms.
 */
void swifthal_ms_sleep(int ms);

/**
 * @brief Cause the current thread to busy wait.
 *
 * @param us Desired duration of wait in us.
 */
void swifthal_us_wait(unsigned int us);

/**
 * @brief Get system uptime.
 *
 * @return Current uptime in milliseconds.
 */
long long swifthal_uptime_get(void);

/**
 * @brief Read the hardware clock.
 *
 * @return Current hardware clock up-counter (in cycles).
 */
unsigned int swifthal_hwcycle_get(void);

/**
 * @brief Convert hardware cycles to nanoseconds
 *
 * @param cycles hardware cycle number
 * @return nanoseconds
 */
unsigned int swifthal_hwcycle_to_ns(unsigned int cycles);