#ifndef _SWIFT_OS_H_
#define _SWIFT_OS_H_


typedef void (*swifthal_task)(void *p1, void *p2, void *p3);

void *swifthal_os_task_create(const char *name,
			      swifthal_task fn, void *p1, void *p2, void *p3,
			      int prio,
			      int stack_size);
void swifthal_os_task_yield(void);

void *swifthal_os_mq_create(int mq_size, int mq_num);
int swifthal_os_mq_destory(void *mp);
int swifthal_os_mq_send(void *mp, void *data, int timeout);
int swifthal_os_mq_recv(void *mp, void *data, int timeout);
int swifthal_os_mq_peek(void *mp, void *data);
int swifthal_os_mq_purge(void *mp);

void *swifthal_os_mutex_create(void);
int swifthal_os_mutex_destroy(void *mutex);
int swifthal_os_mutex_lock(void *mutex, int timeout);
int swifthal_os_mutex_unlock(void *mutex);

void *swifthal_os_sem_create(unsigned int init_cnt, unsigned int limit);
int swifthal_os_sem_destroy(void *sem);
int swifthal_os_sem_take(void *sem, int timeout);
int swifthal_os_sem_give(void *sem);
int swifthal_os_sem_reset(void *sem);

#endif /* _SWIFT_OS_H_ */