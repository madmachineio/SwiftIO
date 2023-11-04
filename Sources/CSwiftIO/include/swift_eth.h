#ifndef _SWIFT_ETH_H_
#define _SWIFT_ETH_H_

#include <stdint.h>
#include <sys/types.h>

#define ETH_EVENT_IFACE_UP              0
#define ETH_EVENT_IFACE_DOWN            1
#define ETH_EVENT_IFACE_CONNECTED       2
#define ETH_EVENT_IFACE_DISCONNECTED    3

/**
 * @brief Set ethernet card MAC address to zephyr iface
 *
 * @param mac MAC address array of ethernet card
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swift_eth_setup_mac(const uint8_t *mac);

/**
 * @brief Register ethernet driver send package function
 *
 * @param send send package function, iface will call the function to send net package
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swift_eth_tx_register(int (*send)(const unsigned char *, int));

/**
 * @brief eth network package revice
 *
 * Ethernet card driver sends the received data packets to zephyr's iface through this API.
 *
 * @param buffer Memory that stores the eth package data
 * @param len Number of eth package date
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swift_eth_rx(uint8_t *buffer, uint16_t len);

/**
 * @brief Send iface status event
 *
 * Notify ethernet of status events.
 *
 * @param speed I2C speed
 * - ETH_EVENT_IFACE_UP = ethernet power up
 * - ETH_EVENT_IFACE_DOWN = ethernet power off
 * - ETH_EVENT_IFACE_CONNECTED = ethernet connect
 * - ETH_EVENT_IFACE_DISCONNECTED = ethernet disconnect
 * @param event_data event with data
 * @param event_data_size Number of event data
 * @param ticks_to_wait Send event timeout, NOUSE
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swift_eth_event_send(int32_t event_id,
			 void *event_data,
			 ssize_t event_data_size,
			 ssize_t ticks_to_wait);

#endif /* _SWIFT_ETH_H_ */
