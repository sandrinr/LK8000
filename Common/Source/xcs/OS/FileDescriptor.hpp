/*
 * Copyright (C) 2012 Max Kellermann <max@duempel.org>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * FOUNDATION OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef XCSOAR_FILE_DESCRIPTOR_HPP
#define XCSOAR_FILE_DESCRIPTOR_HPP

#include "Compiler.h"

#include <assert.h>
#include <unistd.h>
#include <sys/types.h>

#ifdef __linux__
#define HAVE_EVENTFD
#define HAVE_SIGNALFD
#define HAVE_INOTIFY
#include <signal.h>
#endif

/**
 * An OO wrapper for a UNIX file descriptor.
 *
 * This class is unmanaged and trivial; for a managed version, see
 * #UniqueFileDescriptor.
 */
class FileDescriptor {
protected:
  int fd;

public:
  FileDescriptor() = default;
  explicit constexpr FileDescriptor(int _fd):fd(_fd) {}

  constexpr bool operator==(FileDescriptor other) const {
    return fd == other.fd;
  }

  constexpr bool IsDefined() const {
    return fd >= 0;
  }

  /**
   * Returns the file descriptor.  This may only be called if
   * IsDefined() returns true.
   */
  constexpr int Get() const {
    return fd;
  }

  void Set(int _fd) {
    fd = _fd;
  }

  int Steal() {
    assert(IsDefined());

    int _fd = fd;
    fd = -1;
    return _fd;
  }

  void SetUndefined() {
    fd = -1;
  }

  static constexpr FileDescriptor Undefined() {
    return FileDescriptor(-1);
  }

  bool Open(const char *pathname, int flags);
  bool OpenReadOnly(const char *pathname);

#ifdef HAVE_POSIX
  bool OpenNonBlocking(const char *pathname);

  static bool CreatePipe(FileDescriptor &r, FileDescriptor &w);

  /**
   * Enable non-blocking mode on this file descriptor.
   */
  void SetNonBlocking();

  /**
   * Enable blocking mode on this file descriptor.
   */
  void SetBlocking();

  /**
   * Duplicate the file descriptor onto the given file descriptor.
   */
  bool Duplicate(int new_fd) const {
    return ::dup2(Get(), new_fd) == 0;
  }
#endif

#ifdef HAVE_EVENTFD
  bool CreateEventFD(unsigned initval=0);
#endif

#ifdef HAVE_SIGNALFD
  bool CreateSignalFD(const sigset_t *mask);
#endif

#ifdef HAVE_INOTIFY
  bool CreateInotify();
#endif

  /**
   * Close the file descriptor.  It is legal to call it on an
   * "undefined" object.  After this call, IsDefined() is guaranteed
   * to return false, and this object may be reused.
   */
  void Close() {
    ::close(Steal());
  }

  /**
   * Rewind the pointer to the beginning of the file.
   */
  bool Rewind();

  /**
   * Returns the size of the file in bytes, or -1 on error.
   */
  gcc_pure
  off_t GetSize() const;

  ssize_t Read(void *buffer, size_t length) {
    return ::read(fd, buffer, length);
  }

  ssize_t Write(const void *buffer, size_t length) {
    return ::write(fd, buffer, length);
  }

#ifdef HAVE_POSIX
  int Poll(short events, int timeout) const;

  int WaitReadable(int timeout) const;
  int WaitWritable(int timeout) const;
#endif
};

#endif
