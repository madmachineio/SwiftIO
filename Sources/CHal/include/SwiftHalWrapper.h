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
int swifthal_gpio_close(const void *gpio);

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
int swifthal_gpio_config(const void *gpio,
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
int swifthal_gpio_set(const void *gpio, int level);

/**
 * @brief Get input GPIO level
 *
 * @param gpio GPIO handle
 *
 * @retval 0 low level
 * @retval 1 high level
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_get(const void *gpio);

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
int swifthal_gpio_interrupt_config(const void *gpio, swift_gpio_int_mode_t int_mode);

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
int swifthal_gpio_interrupt_callback_install(const void *gpio, void *param, void (*callback)(void *));

/**
 * @brief Uninstall interrupt callback
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_callback_uninstall(const void *gpio);

/**
 * @brief Enable GPIO interrupt
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_enable(const void *gpio);

/**
 * @brief Disable GPIO interrupt
 *
 * @param gpio GPIO handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_gpio_interrupt_disable(const void *gpio);









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
int swifthal_uart_close(const void *uart);

/**
 * @brief Set uart baudrate
 *
 * @param uart 		Uart handle
 * @param baudrate 	Uart baudrate setting in bps
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_baudrate_set(const void *uart, int baudrate);

/**
 * @brief Set uart parity
 *
 * @param uart 		Uart handle
 * @param parity 	Parity bit, use @ref swift_uart_parity
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_parity_set(const void *uart, swift_uart_parity_t parity);

/**
 * @brief Set uart stop bits
 *
 * @param uart 		Uart handle
 * @param stop_bits	Stop bits, use @ref swift_uart_stop_bits
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_stop_bits_set(const void *uart, swift_uart_stop_bits_t stop_bits);

/**
 * @brief Set uart data bits
 *
 * @param uart 		Uart handle
 * @param data_bits 	Data bits, use @ref swift_uart_data_bits
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_swift_uart_data_bits_set(const void *uart, swift_uart_stop_bits_t data_bits);

/**
 * @brief Get uart config information
 *
 * @param uart	Uart handle
 * @param cfg	Uart config, use @ref swift_uart_cfg
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_config_get(const void *uart, swift_uart_cfg_t *cfg);

/**
 * @brief Send one character through UART.
 *
 * @param uart	Uart handle
 * @param c	Character to transmit
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_char_put(const void *uart, unsigned char c);

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
int swifthal_uart_char_get(const void *uart, unsigned char *c, int timeout);

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
int swifthal_uart_write(const void *uart, const unsigned char *buf, int length);

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
int swifthal_uart_read(const void *uart, unsigned char *buf, int length, int timeout);

/**
 * @brief Get data amount in read buffer
 *
 * @param uart Uart handle
 *
 * @return data amount
 */
int swifthal_uart_remainder_get(const void *uart);

/**
 * @brief Clear read buffer of UART
 *
 * @param uart Uart handle
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_uart_buffer_clear(const void *uart);