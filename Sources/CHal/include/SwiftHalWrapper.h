

void swiftHal_msSleep(int t);
void swiftHal_usWait(int t);
long long swiftHal_getUpTimeInMs(void);
unsigned int swiftHal_getClockCycle(void);
unsigned int swiftHal_computeNanoseconds(unsigned int);




typedef struct {
	void *classPtr;
	void (*callback)(void *);
} CallbackWrapper;

typedef struct {
	void *ptr;
	unsigned char idNumber;
	unsigned char direction;
	unsigned char inputMode;
	unsigned char outputMode;
	unsigned char interruptMode;
	unsigned char interruptState;
} DigitalIOObject;

int swiftHal_gpioInit(DigitalIOObject *);
int swiftHal_gpioDeinit(DigitalIOObject *);
int swiftHal_gpioConfig(DigitalIOObject *);
int swiftHal_gpioInterruptConfig(DigitalIOObject *);
int swiftHal_gpioWrite(DigitalIOObject *, int);
int swiftHal_gpioRead(DigitalIOObject *);
int swiftHal_gpioAddCallback(DigitalIOObject *);
int swiftHal_gpioRemoveCallback(DigitalIOObject *);
int swiftHal_gpioEnableCallback(DigitalIOObject *obj);
int swiftHal_gpioDisableCallback(DigitalIOObject *obj);
int swiftHal_gpioAddSwiftMember(DigitalIOObject *obj, void *classPtr, void (*function)(void *));




typedef struct {
	void *ptr;
	unsigned char idNumber;
	int speed;
} I2CObject;

int swiftHal_i2cInit(I2CObject *obj);
int swiftHal_i2cDeinit(I2CObject *obj);
int swiftHal_i2cConfig(I2CObject *obj);
int swiftHal_i2cWrite(I2CObject *obj, unsigned char address, const unsigned char *buf, int length);
int swiftHal_i2cRead(I2CObject *obj, unsigned char address, unsigned char *buf, int length);
int swiftHal_i2cWriteRead(I2CObject *obj, unsigned char address, const unsigned char *wBuf, int wLen, unsigned char *rBuf, int rLen);




typedef struct {
	void *ptr;
	unsigned char idNumber;
	int speed;
} SPIObject;

int swiftHal_spiInit(SPIObject *obj);
int swiftHal_spiDeinit(SPIObject *obj);
int swiftHal_spiConfig(SPIObject *obj);
int swiftHal_spiWrite(SPIObject *obj, const unsigned char *buf, int length);
int swiftHal_spiRead(SPIObject *obj, unsigned char *buf, int length);





typedef struct {
	void *ptr;
	unsigned char idNumber;
	unsigned char parity;
	unsigned char stopBits;
	unsigned char dataBits;
	int baudRate;
	int readBufferLength;
} UARTObject;

int swiftHal_uartInit(UARTObject *obj);
int swiftHal_uartDeinit(UARTObject *obj);
int swiftHal_uartConfig(UARTObject *obj);
int swiftHal_uartWriteChar(UARTObject *obj, unsigned char byte);
int swiftHal_uartWrite(UARTObject *obj, const unsigned char *buf, int length);
unsigned char swiftHal_uartReadChar(UARTObject *obj, int timeout);
int swiftHal_uartRead(UARTObject *obj, unsigned char *buf, int length, int timeout);
int swiftHal_uartCount(UARTObject *obj);
int swiftHal_uartClearBuffer(UARTObject *obj);




typedef struct {
	void *ptr;
	CallbackWrapper callbackWrapper;
	unsigned char timerType;
	int	period;
} TimerObject;

int swiftHal_timerInit(TimerObject *obj);
int swiftHal_timerDeinit(TimerObject *obj);
int swiftHal_timerStart(TimerObject *obj);
int swiftHal_timerStop(TimerObject *obj);
int swiftHal_timerCount(TimerObject *obj);
int swiftHal_timerAddSwiftMember(TimerObject *obj, void *classPtr, void (*function)(void *));




typedef struct {
	int maxFrequency;
	int minFrequency;
} PWMOutInfo;

typedef struct {
	void *ptr;
	const PWMOutInfo info;
	unsigned char idNumber;
} PWMOutObject;


int swiftHal_PWMOutInit(PWMOutObject *obj);
int swiftHal_PWMOutDeinit(PWMOutObject *obj);
int swiftHal_PWMOutSetUsec(PWMOutObject *obj, int period, int pulse);
int swiftHal_PWMOutSetFrequency(PWMOutObject *obj, int fre, float dutycycle);
int swiftHal_PWMOutSetDutycycle(PWMOutObject *obj, float dutycycle);
int swiftHal_PWMOutSuspend(PWMOutObject *obj);
int swiftHal_PWMOutResume(PWMOutObject *obj);





typedef struct {
	int maxRawValue;
	float refVoltage;
} AnalogInInfo;

typedef struct {
	void *ptr;
	const AnalogInInfo info;
	unsigned char idNumber;
} AnalogInObject;

int swiftHal_AnalogInInit(AnalogInObject *obj);
int swiftHal_AnalogInDeinit(AnalogInObject *obj);
int swiftHal_AnalogInRead(AnalogInObject *obj);




typedef struct {
	int maxCountValue;
} CounterInfo;

typedef struct {
	void *ptr;
	const CounterInfo info;
	unsigned char idNumber;
	unsigned char mode;
} CounterObject;

int swiftHal_CounterInit(CounterObject *obj);
int swiftHal_CounterDeinit(CounterObject *obj);
int swiftHal_CounterRead(CounterObject *obj);
void swiftHal_CounterStart(CounterObject *obj);
void swiftHal_CounterStop(CounterObject *obj);
void swiftHal_CounterClear(CounterObject *obj);




#define MAX_FILE_NAME 255

typedef struct {
    unsigned char type;
    char name[MAX_FILE_NAME + 1];
    unsigned int size;
} DirEntry;

//char *swiftHal_FsGetMountPoint(void);
void *swiftHal_FsOpen(const char *path);
int swiftHal_FsClose(const void* fp);
int swiftHal_FsRemove(const char *path);
//int swiftHal_FsRename(char *from, char *to);
int swiftHal_FsWrite(const void* fp, const void *ptr, unsigned int size);
int swiftHal_FsRead(const void* fp, void *ptr, unsigned int size);
int swiftHal_FsSeek(const void* fp, int offset, int whence);
int swiftHal_FsTell(const void* fp);
//int swiftHal_FsTruncate(const void* fp, unsigned int length);
int swiftHal_FsSync(const void* fp);
//int swiftHal_Fsmkdir(char *path);
//void *swiftHal_FsOpenDir(char *path);
//int swiftHal_FsReadDir(void *dp, DirEntry *entry);
//int swiftHal_FsCloseDir(void *dp);
int swiftHal_FsStat(const char *path, DirEntry *entry);
//int swiftHal_FsStatvfs(char *path, DirEntry *stat);