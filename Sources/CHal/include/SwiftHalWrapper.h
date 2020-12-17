typedef struct {
	void *classPtr;
	void (*callback)(void *);
} CallbackWrapper;










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
int swifthal_spi_close(const void *spi);

/**
 * @brief Config spi speed
 *
 * @param spi SPI Handle
 * @param speed SPI speed
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_spi_config(const void *spi, int speed);

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
int swifthal_spi_write(const void *spi, const unsigned char *buf, int length);

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
int swifthal_spi_read(const void *spi, unsigned char *buf, int length);

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
int swifthal_spi_async_write(const void *spi, const unsigned char *buf, int length);

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
int swifthal_spi_async_read(const void *spi, unsigned char *buf, int length);









/**
 * @brief Structure to receive pwm information
 *
 * @param max_frequency max pwm frequency
 * @param min_frequency min pwm frequency
 */
struct swift_pwm_info {
	int max_frequency;
	int min_frequency;
};

typedef struct swift_pwm_info swift_pwm_info_t;

/**
 * @brief Open a pwm
 *
 * @param id PWM id
 * @return PWM handle, NULL is fail
 */
void *swifthal_pwm_open(int id);

/**
 * @brief Close pwm
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_close(const void *pwm);

/**
 * @brief Set pwm paramater
 *
 * @param pwm PWM handle
 * @param period PWM period
 * @param pulse PWM high level pulse width
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_set(const void *pwm, int period, int pulse);

/**
 * @brief Suspend pwm output
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_suspend(const void *pwm);

/**
 * @brief Resume pwm output
 *
 * @param pwm PWM handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_resume(const void *pwm);

/**
 * @brief Get pwm infomation
 *
 * @param pwm PWM handle
 * @param info pwm information, use @ref swift_pwm_info
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_pwm_info_get(const void *pwm, swift_pwm_info_t *info);









/**
 * @brief Timer trigger type
 */
enum swift_timer_type {
	/** Only trigger once */
	SWIFT_TIMER_TYPE_ONESHOT,
	/** Periodic trigger */
	SWIFT_TIMER_TYPE_PERIOD,
};

typedef enum swift_timer_type swift_timer_type_t;

/**
 * @brief Open a timer
 *
 * @return void*	Timer handle,NULL if not found or cannot be used.
 */
void *swifthal_timer_open();

/**
 * @brief Close a timer
 *
 * @param timer Timer handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_close(const void *timer);

/**
 * @brief Start timer
 *
 * @param timer Timer handle
 * @param type		Trigger type of timer.
 * @param period	Timer period.
 * 
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_start(const void *timer, swift_timer_type_t type, int period);

/**
 * @brief Stop timer
 *
 * @param timer Timer handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_stop(const void *timer);

/**
 * @brief Add callback for timer expire
 *
 * @param timer		Timer handle
 * @param param		callback param
 * @param callback	Function to invoke each time the timer expires.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_timer_add_callback(const void *timer, void *param, void (*callback)(void *));

/**
 * @brief Read timer status.
 *
 * This routine reads the timer's status, which indicates the number of times
 * it has expired since its status was last read.
 *
 * Calling this routine resets the timer's status to zero.
 *
 * @param timer Timer handle
 *
 * @return Timer status.
 */
unsigned int swifthal_timer_status_get(const void *timer);









/** @brief counter work mode. */
enum swift_counter_mode {
	SWIFT_COUNTER_RISING_EDGE       = 1,
	SWIFT_COUNTER_BOTH_EDGE         = 2,
};

typedef enum swift_counter_mode swift_counter_mode_t;

/**
 * @brief Structure to receive adc information
 *
 * @param max_count_value adc refer volage
 */
struct swift_counter_info {
	int max_count_value;
};

typedef struct swift_counter_info swift_counter_info_t;

/**
 * @brief Open counter
 *
 * @param id Counter id
 * @param mode Count mode
 * - SWIFT_COUNTER_RISING_EDGE = Count rising edges
 * - SWIFT_COUNTER_BOTH_EDGE = Count rising and falling edges
 * @return Counter handle
 */
void *swifthal_counter_open(int id);

/**
 * @brief Close counter
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_close(const void *counter);

/**
 * @brief Read count result
 *
 * @param counter Counter Handle
 *
 * @retval Positive indicates the count result.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_read(const void *counter);

/**
 * @brief Start count
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_start(const void *counter, swift_counter_mode_t mode);

/**
 * @brief Stop count
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_stop(const void *counter);

/**
 * @brief Reset count result to 0
 *
 * @param counter Counter handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_clear(const void *counter);

/**
 * @brief Get counter infomation
 *
 * @param counter counter handle
 * @param info conter information, use @ref swift_counter_info
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_counter_info_get(const void *counter, swift_counter_info_t *info);