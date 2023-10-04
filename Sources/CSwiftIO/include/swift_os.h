#ifndef _SWIFT_OS_H_
#define _SWIFT_OS_H_

#include <stdint.h>
#include <sys/types.h>

typedef void (*swifthal_task)(void *p1, void *p2, void *p3);

/**
 * @brief Create thread
 *
 * Supports up to 16 threads. The thread priority ranges from -16 to 15.
 * The smaller the value, the higher the priority. If it is greater than 0,
 * it is a preemqtive thread, and if it is less than or equal to 0,
 * it is a cooperative thread.
 *
 * @param name thread name
 * @param fn thread entry function
 * @param p1 1st entry point parameter.
 * @param p2 2nd entry point parameter.
 * @param p3 3rd entry point parameter.
 * @param prio thread priority.
 * @param stack_size Stack size in bytes.
 *
 * @return thread handle
 */
void *swifthal_os_task_create(char *name,
			      swifthal_task fn, void *p1, void *p2, void *p3,
			      int prio,
			      int stack_size);

/**
 * @brief Yield the current thread.
 *
 * This routine causes the current thread to yield execution to another
 * thread of the same or higher priority. If there are no other ready thread
 * of the same or higher priority, the routine returns immediately.
 *
 * @return N/A
 */
void swifthal_os_task_yield(void);

/**
 * @brief Create message queue
 *
 * Supports up to 16 message queue.
 *
 * @param mq_size Message size (in bytes).
 * @param mq_num Maximum number of messages that can be queued.
 *
 * @return message queue handle
 */
const void *swifthal_os_mq_create(ssize_t mq_size, ssize_t mq_num);

/**
 * @brief Destroy message queue
 *
 * @param mq message queue handle.
 *
 * @return message queue handle
 */
int swifthal_os_mq_destroy(const void *mq);

/**
 * @brief Send a message to a message queue.
 *
 * @note The message content is copied from data into msgq and the data
 * pointer is not retained, so the message content will not be modified
 * by this function.  Allowed for use in ISR
 *
 * @param mq message queue handle.
 * @param data Pointer to the message.
 * @param timeout Non-negative waiting period to add the message,
 *                or 0 means no wait and -1 means wait forever.
 *
 * @retval 0 Message sent.
 * @retval -ENOMSG Returned without waiting or queue purged.
 * @retval -EAGAIN Waiting period timed out.
 */
int swifthal_os_mq_send(const void *mq, const void *data, int timeout);

/**
 * @brief Receive a message from a message queue.
 *
 * @note timeout must be set to -1 if called from ISR.
 *
 * @param mq message queue handle.
 * @param data Address of area to hold the received message.
 * @param timeout Waiting period to receive the message,
 *                or 0 means no wait and -1 means wait forever.
 *
 * @retval 0 Message received.
 * @retval -ENOMSG Returned without waiting.
 * @retval -EAGAIN Waiting period timed out.
 */
int swifthal_os_mq_recv(const void *mq, void *data, int timeout);

/**
 * @brief Peek/read a message from a message queue.
 *
 * This routine reads a message from message queue in a "first in,
 * first out" manner and leaves the message in the queue. Allowed for use in ISR
 *
 * @param mq Address of the message queue.
 * @param data Address of area to hold the message read from the queue.
 *
 * @retval 0 Message read.
 * @retval -ENOMSG Returned when the queue has no message.
 */
int swifthal_os_mq_peek(const void *mq, void *data);

/**
 * @brief Purge a message queue.
 *
 * This routine discards all unreceived messages in a message queue's ring
 * buffer. Any threads that are blocked waiting to send a message to the
 * message queue are unblocked and see an -ENOMSG error code.
 *
 * @param mq Address of the message queue.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_os_mq_purge(const void *mq);

/**
 * @brief Create a mutex.
 *
 * This routine create a mutex , prior to its first use.Supports up to 32 mutex.
 *
 * Upon completion, the mutex is available and does not have an owner.
 *
 * @return mutex handle
 *
 */
const void *swifthal_os_mutex_create(void);

/**
 * @brief Destory mutex
 *
 * @param mutex mutex handle.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_os_mutex_destroy(const void *mutex);

/**
 * @brief Lock a mutex.
 *
 * This routine locks mutex. If the mutex is locked by another thread,
 * the calling thread waits until the mutex becomes available or until
 * a timeout occurs.
 *
 * A thread is permitted to lock a mutex it has already locked. The operation
 * completes immediately and the lock count is increased by 1.
 *
 * Mutexes may not be locked in ISRs.
 *
 * @param mutex Handle of the mutex.
 * @param timeout Waiting period to lock the mutex,
 *                or 0 means no wait and -1 means wait forever.
 *
 * @retval 0 Mutex locked.
 * @retval -EBUSY Returned without waiting.
 * @retval -EAGAIN Waiting period timed out.
 */
int swifthal_os_mutex_lock(const void *mutex, int timeout);

/**
 * @brief Unlock a mutex.
 *
 * This routine unlocks mutex. The mutex must already be locked by the
 * calling thread.
 *
 * The mutex cannot be claimed by another thread until it has been unlocked by
 * the calling thread as many times as it was previously locked by that
 * thread.
 *
 * Mutexes may not be unlocked in ISRs, as mutexes must only be manipulated
 * in thread context due to ownership and priority inheritance semantics.
 *
 * @param mutex Handle of the mutex.
 *
 * @retval 0 Mutex unlocked.
 * @retval -EPERM The current thread does not own the mutex
 * @retval -EINVAL The mutex is not locked
 *
 */
int swifthal_os_mutex_unlock(const void *mutex);

/**
 * @brief Create a semaphore.
 *
 * This routine initializes a semaphore object, prior to its first use.
 * Supports up to 16 semaphore.
 *
 * @param init_cnt Initial semaphore count.
 * @param limit Maximum permitted semaphore count.
 *
 *
 * @return semaphone handle
 *
 */
const void *swifthal_os_sem_create(uint32_t init_cnt, uint32_t limit);

/**
 * @brief Destory semaphone
 *
 * @param sem semaphone handle.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_os_sem_destroy(const void *sem);

/**
 * @brief Take a semaphore.
 *
 * This routine takes sem.
 *
 * @note timeout must be set to 0 if called from ISR.
 *
 *
 * @param sem Handle of the semaphore.
 * @param timeout Waiting period to take the semaphore,
 *                or 0 means no wait and -1 means wait forever.
 *
 * @retval 0 Semaphore taken.
 * @retval -EBUSY Returned without waiting.
 * @retval -EAGAIN Waiting period timed out,
 *			or the semaphore was reset during the waiting period.
 */
int swifthal_os_sem_take(const void *sem, int timeout);

/**
 * @brief Give a semaphore.
 *
 * This routine gives  sem, unless the semaphore is already at its maximum
 * permitted count.
 *
 * @param sem Handle of the semaphore.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_os_sem_give(const void *sem);

/**
 * @brief Resets a semaphore's count to zero.
 *
 * This routine sets the count of sem to zero.
 * Any outstanding semaphore takes will be aborted
 * with -EAGAIN.
 *
 * @param sem Handle of the semaphore.
 *
 * @retval 0 If successful.
 * @retval Negative errno code if failure.
 */
int swifthal_os_sem_reset(const void *sem);

#endif /* _SWIFT_OS_H_ */