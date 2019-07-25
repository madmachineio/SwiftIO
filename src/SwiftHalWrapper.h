void swiftHal_msSleep(unsigned int t);
void swiftHal_usWait(unsigned int t);
unsigned int swiftHal_getUpTimeInMs32(void);
long long swiftHal_getUpTimeInMs64(void);
unsigned int swiftHal_getClockCycle(void);
unsigned int swiftHal_computeNanoseconds(unsigned int);





typedef struct {
	void *ptr;
	unsigned char id;
	unsigned char redState;
	unsigned char greenState;
	unsigned char blueState;
} RGBLEDObject;

int swiftHal_rgbInit(RGBLEDObject *);
int swiftHal_rgbDeinit(RGBLEDObject *);
int swiftHal_rgbConfig(RGBLEDObject *);






















typedef void (*VoidCallbackType)(void);

typedef struct {
	void *ptr;
	unsigned char id;
	unsigned char direction;
	unsigned char inputMode;
	unsigned char outputMode;
	unsigned char callbackMode;
	VoidCallbackType callback;
} DigitalIOObject;

int swiftHal_gpioInit(DigitalIOObject *);
int swiftHal_gpioDeinit(DigitalIOObject *);
int swiftHal_gpioConfig(DigitalIOObject *);
int swiftHal_gpioWrite(DigitalIOObject *, unsigned int);
int swiftHal_gpioRead(DigitalIOObject *);
int swiftHal_gpioAddCallback(DigitalIOObject *);
int swiftHal_gpioRemoveCallback(DigitalIOObject *);





typedef struct {
	void *ptr;
	unsigned char id;
	unsigned int speed;
} I2CObject;


int swiftHal_i2cInit(I2CObject *obj);
int swiftHal_i2cDeinit(I2CObject *obj);
int swiftHal_i2cConfig(I2CObject *obj);
int swiftHal_i2cWrite(I2CObject *obj, unsigned char address, const unsigned char *buf, unsigned int length);
int swiftHal_i2cRead(I2CObject *obj, unsigned char address, unsigned char *buf, unsigned int length);
int swiftHal_i2cRead8bitReg(I2CObject *obj, unsigned char address, unsigned char reg, unsigned char *buf, unsigned int length);
int swiftHal_i2cRead16bitReg(I2CObject *obj, unsigned char address, unsigned short reg, unsigned char *buf, unsigned int length);







typedef struct {
	void *ptr;
	unsigned char id;
	unsigned char parity;
	unsigned char stopBits;
	unsigned char dataBits;
	unsigned int baudRate;
	unsigned int readBufferLength;
} UARTObject;

int swiftHal_uartInit(UARTObject *obj);
int swiftHal_uartConfig(UARTObject *obj);
int swiftHal_uartDeinit(UARTObject *obj);
int swiftHal_uartWriteChar(UARTObject *obj, unsigned char byte);
int swiftHal_uartWrite(UARTObject *obj, const unsigned char *buf, unsigned int length);
unsigned char swiftHal_uartReadChar(UARTObject *obj);
int swiftHal_uartRead(UARTObject *obj, unsigned char *buf, unsigned int length);
unsigned int swiftHal_uartCount(UARTObject *obj);
int swiftHal_uartClearBuffer(UARTObject *obj);





typedef struct {
	void *ptr;
	VoidCallbackType expiryCallback;
	unsigned char timerType;
	int	period;
} TimerObject;


int swiftHal_timerInit(TimerObject *obj);
int swiftHal_timerDeinit(TimerObject *obj);
int swiftHal_timerStart(TimerObject *obj);
int swiftHal_timerStop(TimerObject *obj);
unsigned int swiftHal_timerCount(TimerObject *obj);







typedef struct {
	void *ptr;
	unsigned char id;
	unsigned int period;
	unsigned int pulse;
	unsigned int countPerSecond;
} PWMOutObject;


int swiftHal_PWMOutConfig(PWMOutObject *obj);
int swiftHal_PWMOutUpdate(PWMOutObject *obj);
int swiftHal_PWMOutInit(PWMOutObject *obj);
int swiftHal_PWMOutDeinit(PWMOutObject *obj);




typedef struct {
	void *ptr;
	unsigned char id;
	unsigned int resolution;
	float refVoltage;
} AnalogInObject;


int swiftHal_AnalogInInit(AnalogInObject *obj);
int swiftHal_AnalogInDeinit(AnalogInObject *obj);
unsigned int swiftHal_AnalogInRead(AnalogInObject *obj);
