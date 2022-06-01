# ``SwiftIO/SPI``

## Topics

### Initializer

- ``init(_:speed:csPin:CPOL:CPHA:bitOrder:)``

### Reading data

- ``read(into:)``
- ``read(into:count:)-8i18b``
- ``read(into:count:)-1ae4o``

### Writing data

- ``write(_:)``
- ``write(_:count:)-x9v4``
- ``write(_:count:)-71bmp``

### Writing and reading data

- ``transceive(_:into:readCount:)``
- ``transceive(_:writeCount:into:readCount:)``

### Configuring SPI

- ``setSpeed(_:)``
- ``getSpeed()``
- ``setMode(CPOL:CPHA:bitOrder:)``
- ``getMode()``
- ``BitOrder``
