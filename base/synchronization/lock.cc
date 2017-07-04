#if !defined (_DEBUG)

#include "synchronization/lock.h"
#include "thread/platform_thread.h"
#include "logic/logic_comm.h"
namespace base {

Lock::Lock()
:lock_(){
    owned_by_thread_ = false;
    owning_thread_id_ = static_cast<pid_t>(0);
}

void Lock::AsserAcquired() const {
    LOG_MSG2("owning_thread_id_[%d] is %d",
            owning_thread_id_,PlatformThread::CurrentId());
}

void Lock::CheckHeldAndUnmark() {
    owned_by_thread_ = false;
    owning_thread_id_ = static_cast<pid_t>(0);
}

void Lock::CheckUnheldAndMark() {
    owned_by_thread_ = true;
    owning_thread_id_ = PlatformThread::CurrentId();
}


}

#endif
