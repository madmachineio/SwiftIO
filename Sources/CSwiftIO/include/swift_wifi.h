#ifndef _SWIFT_WIFI_H_
#define _SWIFT_WIFI_H_

#define SWIFT_WIFI_SSID_MAX_LEN 32
#define SWIFT_WIFI_IPV4_STR_LEN 17
/** @brief wifi security type */
enum swift_wifi_security_type {
	SWIFT_WIFI_SECURITY_TYPE_NONE = 0,
	SWIFT_WIFI_SECURITY_TYPE_PSK,
};

/**
 * @brief WIFI status
 *
 * @param ap_mode wifi work mode, 1 ap mode, 2 station mode
 * @param connected wifi connected status, 1 connected, 0 disconnected, only for station mode
 * @param ip ip address
 * @param gateway ip gateway
 * @param netmask ip netmask
 * @param mac wifi device mac address
 * @param ssid wifi ssid, only for station mode
 * @param ssid_length wifi ssid name length, only for station mode
 * @param mtu Maximum Transmission Unit
 * @param rssi wifi signal level, only for station mode, no support yet
 *
 */
struct swift_wifi_status {
	int ap_mode;
	int connected;

	char ip[SWIFT_WIFI_IPV4_STR_LEN];
	char gateway[SWIFT_WIFI_IPV4_STR_LEN];
	char netmask[SWIFT_WIFI_IPV4_STR_LEN];

	char mac[6];
	char ssid[SWIFT_WIFI_SSID_MAX_LEN];
	unsigned char ssid_length;
	int mtu;
	int rssi;
};

typedef struct swift_wifi_status swift_wifi_status_t;

/**
 * @brief Structure to receive wifi scan result
 *
 * @param ssid wifi ssid name
 * @param ssid_length wifi ssid name length
 * @param channel wifi channel
 * @param security Wifi security type
 * @param rssi wifi signal level
 *
 */
struct swift_wifi_scan_result {
	char ssid[SWIFT_WIFI_SSID_MAX_LEN];
	unsigned char ssid_length;

	unsigned char channel;
	enum swift_wifi_security_type security;
	int rssi;
};

typedef struct swift_wifi_scan_result swift_wifi_scan_result_t;

/**
 * @brief Scan wifi and return results
 *
 * Block scan, scan fininsh API return
 *
 * @param results save scan result, @ref swift_wifi_scan_result
 * @param num results size
 *
 * @return Number of valid wifi
 */
int swift_wifi_scan(swift_wifi_scan_result_t *results, int num);

/**
 * @brief Connect wifi
 *
 * @param ssid	wifi ssid name
 * @param ssid_length	ssid name length
 * @param psk	wifi password, if no password, user NULL
 * @param psk_length password length
 *
 *  @retval 0 Success
 * @retval -ERRNO errno code if error
 *
 */
int swift_wifi_connect(char *ssid, int ssid_length, char *psk, int psk_length);

/**
 * @brief Disconnect wifi
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 *
 */
int swift_wifi_disconnect(void);

/**
 * @brief Set Wifi ap mode
 *
 * @param enable	1,enable AP mode, 0 disable AP mode
 * @param ssid		AP ssid name
 * @param ssid_length	ssid name length, <=32
 * @param psk		AP password, if no need password, use NULL
 * @param psk_length password length, 8~64
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 *
 */
int swift_wifi_ap_mode_set(int enable, char *ssid, int ssid_length, char *psk, int psk_length);

/**
 * @brief Get wifi status
 *
 * @param status wifi status @ref swift_wifi_status
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 *
 */
int swift_wifi_status_get(swift_wifi_status_t *status);


#endif /* _SWIFT_WIFI_H_ */
