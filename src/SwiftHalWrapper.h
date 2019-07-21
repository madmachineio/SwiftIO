void swiftHal_msSleep(int t);

void swiftHal_usWait(int t);

unsigned int swiftHal_getUpTimeInMs32(void);

long long swiftHal_getUpTimeInMs64(void);

unsigned int swiftHal_getClockCycle(void);

unsigned int swiftHal_computeNanoseconds(unsigned int);


typedef void (*GpioCallbackType)(void);

typedef struct {
	void *ptr;
	unsigned char id;
	unsigned char direction;
	unsigned char inputMode;
	unsigned char outputMode;
	unsigned char callbackMode;
	GpioCallbackType callback;
} DigitalIOObject;

int swiftHal_pinInit(DigitalIOObject *);
int swiftHal_pinDeinit(DigitalIOObject *);
int swiftHal_pinConfig(DigitalIOObject *);
int swiftHal_pinWrite(DigitalIOObject *, unsigned int);
int swiftHal_pinRead(DigitalIOObject *);
int swiftHal_pinAddCallback(DigitalIOObject *);
int swiftHal_pinRemoveCallback(DigitalIOObject *);





typedef struct {
	void *ptr;
	unsigned char id;
	unsigned int speed;
} I2CObject;


int swiftHal_i2cInit(I2CObject *obj);
int swiftHal_i2cDeinit(I2CObject *obj);
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
	unsigned int readBufLength;
} UARTObject;

int swiftHal_uartInit(UARTObject *obj);
int swiftHal_uartConfig(UARTObject *obj);
int swiftHal_uartDeinit(UARTObject *obj);
int swiftHal_uartWriteChar(UARTObject *obj, unsigned char byte);
int swiftHal_uartWrite(UARTObject *obj, const char *buf, unsigned int length);
unsigned char swiftHal_uartReadChar(UARTObject *obj);
int swiftHal_uartRead(UARTObject *obj, unsigned char *buf, unsigned int length);
unsigned int swiftHal_uartCount(UARTObject *obj);




typedef void (*VoidCallbackType)(void);

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
