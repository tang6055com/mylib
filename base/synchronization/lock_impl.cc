#include <synchronization/lock_impl.h>
#include <assert.h>
namespace base {
namespace internal {

LockImpl::LockImpl() {

#ifndef _DEBUG
    pthread_mutexattr_t mta;
    int rv = pthread_mutexattr_init(&mta);
    assert(rv == 0);
    rv = pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_ERRORCHECK);
    assert(rv == 0);

    rv = pthread_mutex_init(&os_lock_, &mta);
    assert(rv == 0);

    rv = pthread_mutex_destroy(&os_lock_);
    assert(rv == 0);
#else
    pthread_mutex_init(&os_lock_,NULL);
#endif
}

LockImpl::~LockImpl() {
    int rv = pthread_mutex_destroy(&os_lock_);
#ifndef _DEBUG
    assert(rv == 0);
#endif
}

bool LockImpl::Try() {
    int rv = pthread_mutex_trylock(&os_lock_);
    return rv == 0;
}

void LockImpl::Lock() {
    int rv = pthread_mutex_lock(&os_lock_);
#ifndef _DEBUG
    assert(rv == 0);
#endif
}

void LockImpl::Unlock() {
    int rv = pthread_mutex_unlock(&os_lock_); 
#ifndef _DEBUG
    assert(rv == 0);
#endif
}

}

}
