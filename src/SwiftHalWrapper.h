void swiftHal_msSleep(int t);

void swiftHal_usWait(int t);




int swiftHal_pinConfig(int pin, int config);

int swiftHal_pinWrite(int pin, int val);

int swiftHal_pinRead(int pin);




int swiftHal_i2cConfig(int dev, int mode);

int swiftHal_i2cWrite(int dev, unsigned char address, const unsigned char *buf, int length);

int swiftHal_i2cRead(int dev, unsigned char address, unsigned char *buf, int length);

int swiftHal_i2cWriteRead(int dev, unsigned char address, const char *writeBuf, int writeLength, unsigned char *readBuf, int readLength);
