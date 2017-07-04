#ifndef BASE_SYNCHRONIZATION_LOCK_H_
#define BASE_SYNCHRONIZATION_LOCK_H_
#pragma once

#include "synchronization/lock_impl.h"

namespace base {

class Lock {
public:
#if defined _DEBUG
    Lock() : lock_() {}
    ~Lock() {}
    void Acquire() { lock_.Lock(); }
    void Release() { lock_.Unlock(); }

    bool Try() { return lock_.Try(); }

    void AsserAcquired() const {}
#else
    Lock();
    ~Lock() {}

    void Acquire() {
        lock_.Lock();
        CheckUnheldAndMark();
    }

    void Release() {
        CheckHeldAndUnmark();
        lock_.Unlock();
    }

    bool Try() {
        bool rv = lock_.Try();
        if(rv) {
            CheckUnheldAndMark();
        }
        return rv;
    }
    // The posix implementation of ConditionVariable needs to be able
    // to see our lock and tweak our debugging counters, as it releases
    // and acquires locks inside of pthread_cond_{timed,}wait.
    void AsserAcquired() const;
#endif

    friend class ConditionVariable;
private:
#if !defined _DEBUG
      // Members and routines taking care of locks assertions.
      // Note that this checks for recursive locks and allows them
      // if the variable is set.  This is allowed by the underlying implementation
      // on windows but not on Posix, so we're doing unneeded checks on Posix.
      // It's worth it to share the code.
      void CheckHeldAndUnmark();
      void CheckUnheldAndMark();
      bool owned_by_thread_;
      pid_t  owning_thread_id_;
#endif
    internal::LockImpl lock_;
    DISALLOW_COPY_AND_ASSIGN(Lock);
};


}

#endif
