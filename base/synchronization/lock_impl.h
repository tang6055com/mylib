#ifndef BASE_SYNCHRONIZATION_LOCK_IMPL_H_
#define BASE_SYNCHRONIZATION_LOCK_IMPL_H_
#pragma once

#include <pthread.h>
#include "basic/basictypes.h"

namespace base {

namespace internal {

class LockImpl {
public:
    typedef pthread_mutex_t OSLockType;
    
    
    LockImpl();
    ~LockImpl();

    // If the lock is not held, take it and return true.  If the lock is already
    // held by something else, immediately return false.
    bool Try();

    //Take the lock, blocking until it is available if necessary.
    void Lock();

     //Release the lock.  This must only be called by the lock's holder: after
      // a successful call to Try, or a call to Lock.
    void Unlock();

    OSLockType* os_lock() {return &os_lock_;}
private:
    OSLockType os_lock_;
    DISALLOW_COPY_AND_ASSIGN(LockImpl);
};

}
}


#endif
