#include "thread/platform_thread.h"

#include <sys/prctl.h>
#include <sys/resource.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <unistd.h>

namespace base {

//static
PlatformThreadId PlatformThread::CurrentId(){
    return pthread_self();
}

void PlatformThread::YieldCurrentThread() {
    sched_yield();
}

}
