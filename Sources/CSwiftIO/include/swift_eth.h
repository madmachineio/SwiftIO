#ifndef _SWIFT_ETH_H_
#define _SWIFT_ETH_H_

#define ETH_EVENT_IFACE_UP              0
#define ETH_EVENT_IFACE_DOWN            1
#define ETH_EVENT_IFACE_CONNECTED       2
#define ETH_EVENT_IFACE_DISCONNECTED    3

int swift_eth_setup_mac(const unsigned char *mac);

int swift_eth_tx_register(int (*send)(unsigned char *, int));

int swift_eth_rx(void *buffer, unsigned short len);

int swift_eth_event_send(int event_id,
			 void *event_data,
			 int event_data_size,
			 int ticks_to_wait);

#endif /* _SWIFT_ETH_H_ */
