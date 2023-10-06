/*
 * @Copyright (c) 2020, MADMACHINE LIMITED
 * @Author: Frank Li(lgl88911@163.com)
 * @SPDX-License-Identifier: MIT
 */

#ifndef _SWIFT_FS_H_
#define _SWIFT_FS_H_

#include <stdint.h>
#include <sys/types.h>

#define SWIFT_FS_O_READ       0x01
#define SWIFT_FS_O_WRITE      0x02
#define SWIFT_FS_O_RDWR       (SWIFT_FS_O_READ | SWIFT_FS_O_WRITE)
#define SWIFT_FS_O_MODE_MASK  0x03

#define SWIFT_FS_O_CREATE     0x10
#define SWIFT_FS_O_APPEND     0x20
#define SWIFT_FS_O_FLAGS_MASK 0x30

#define SWIFT_FS_O_MASK       (SWIFT_FS_O_MODE_MASK | SWIFT_FS_O_FLAGS_MASK)

#define SWIFT_FS_SEEK_SET 0
#define SWIFT_FS_SEEK_CUR 1
#define SWIFT_FS_SEEK_END 2

enum swift_fs_dir_entry_type {
	SWIFT_FS_DIR_ENTRY_FILE = 0,
	SWIFT_FS_DIR_ENTRY_DIR
};

typedef enum swift_fs_dir_entry_type swift_fs_dir_entry_type_t;

/**
 * @brief Structure to receive file or directory information
 *
 * @param type Whether file or directory, use @ref swift_fs_dir_entry_type
 * @param name Name of directory or file
 * @param size Size of file. 0 if directory
 */
struct swift_fs_dirent {
	swift_fs_dir_entry_type_t type;
	char name[256];
	ssize_t size;
};

typedef struct swift_fs_dirent swift_fs_dirent_t;

/**
 * @brief Structure to receive volume statistics
 *
 *
 * @param f_bsize Optimal transfer block size
 * @param f_frsize Allocation unit size
 * @param f_blocks Size of FS in f_frsize units
 * @param f_bfree Number of free blocks
 */
struct swift_fs_statvfs {
	unsigned long f_bsize;
	unsigned long f_frsize;
	unsigned long f_blocks;
	unsigned long f_bfree;
};

typedef struct swift_fs_statvfs swift_fs_statvfs_t;


/**
 * @brief File open
 *
 * Opens or creates, if does not exist, file depending on flags provided
 * and associates a stream with it.
 *
 * @param fp   Pointer to save the file descriptor
 * @param path The path with name of file to open
 * @param flags The mode flags
 *
 * @p flags can be empty, or combination of one or more of following flags:
 *   SWIFT_FS_O_READ    open for read
 *   SWIFT_FS_O_WRITE   open for write
 *   SWIFT_FS_O_RDWR    open for read/write (<tt>FS_O_READ | FS_O_WRITE</tt>)
 *   SWIFT_FS_O_CREATE  create file if it does not exist
 *   SWIFT_FS_O_APPEND  move to end of file before each write
 *
 * @retval 0 Success
 */
int swifthal_fs_open(void **fp, const char *path, uint8_t flags);

/**
 * @brief Close file
 *
 * @param fp	File handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_close(void *fp);

/**
 * @brief Deletes the specified file or directory
 *
 * @param path Path to the file or directory to delete
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_remove(const char *path);

/**
 * @brief File or directory rename
 *
 * @param from The source path.
 * @param to The destination path.
 *
 * @retval 0 Success;
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_rename(const char *from, char *to);

/**
 * @brief File write

 *
 * @param fp File handle
 * @param buf Pointer to the data buffer
 * @param size Number of bytes to be write
 *
 * @return Number of bytes written. On success, it will be equal to the number
 * of bytes requested to be written. Any other value, indicates an error. Will
 * return -ERRNO code on error.
 */
int swifthal_fs_write(void *fp, const void *buf, ssize_t size);

/**
 * @brief File read
 *
 * Reads items of data of size bytes long.
 *
 * @param fp File handle
 * @param buf Pointer to the data buffer
 * @param size Number of bytes to be read
 *
 * @return Number of bytes read. On success, it will be equal to number of
 * items requested to be read. Returns less than number of bytes
 * requested if there are not enough bytes available in file. Will return
 * -ERRNO code on error.
 */
int swifthal_fs_read(void *fp, void *buf, ssize_t size);

/**
 * @brief File seek
 *
 * @param fp File handle
 * @param offset Relative location to move the file pointer to
 * @param whence Relative location from where offset is to be calculated.
 * - SWIFT_FS_SEEK_SET = from beginning of file
 * - SWIFT_FS_SEEK_CUR = from current position,
 * - SWIFT_FS_SEEK_END = from end of file.
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error.
 */
int swifthal_fs_seek(void *fp, ssize_t offset, int whence);

/**
 * @brief Get current file position.
 *
 * @param fp File handle
 *
 * @retval position Current position in file
 * Current revision does not validate the file object.
 */
int swifthal_fs_tell(void *fp);

/**
 * @brief Change the size of an open file
 *
 * @note In the case of expansion, if the volume got full during the
 * expansion process, the function will expand to the maximum possible length
 * and returns success. Caller should check if the expanded size matches the
 * requested length.
 *
 * @param fp File handle
 * @param length New size of the file in bytes
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_truncate(void *fp, ssize_t length);

/**
 * @brief Flushes any cached write of an open file
 *
 * @param fp File handle
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_sync(void *fp);

/**
 * @brief Directory create
 *
 * @param path Path to the directory to create
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_mkdir(const char *path);

/**
 * @brief Directory open
 *
 * @param dp   Pointer to save the directory descriptor
 * @param path Path to the directory to open
 *
 * @retval Directory handle, NULL is fail
 */
int swifthal_fs_opendir(void **dp, const char *path);

/**
 * @brief Directory read entry
 *
 * Reads directory entries of a open directory.
 *
 * @note: Most existing underlying file systems do not generate POSIX
 * special directory entries "." or "..".  For consistency the
 * abstraction layer will remove these from lower layer results so
 * higher layers see consistent results.
 *
 * @param dp Pointer to the directory object
 * @param entry Pointer to @ref swift_fs_dirent structure to read the entry into
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 * @return In end-of-dir condition, this will return 0 and set
 * entry->name[0] = 0
 */
int swifthal_fs_readdir(void *dp, swift_fs_dirent_t *entry);

/**
 * @brief Directory close
 *
 * @param dp Pointer to the directory object
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_closedir(void *dp);

/**
 * @brief File or directory status
 *
 * @param path Path to the file or directory
 * @param entry Pointer to @ref swift_fs_dirent structure to fill if file or directory
 * exists.
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_stat(const char *path, swift_fs_dirent_t *entry);

/**
 * @brief Retrieves statistics of the file system volume
 *
 * Returns the total and available space in the file system volume.
 *
 * @param path Path to the mounted directory
 * @param stat Pointer to @ref swift_fs_statvfs structure to receive the fs statistics
 *
 * @retval 0 Success
 * @retval -ERRNO errno code if error
 */
int swifthal_fs_statfs(const char *path, swift_fs_statvfs_t *stat);

#endif /*_SWIFT_FS_H_*/
