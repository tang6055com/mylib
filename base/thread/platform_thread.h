#ifndef BASE_THREADE_PLATFORM_THREAD_H_
#define BASE_THREADE_PLATFORM_THREAD_H_

#include "basic/basictypes.h"
#include <pthread.h>


namespace base {

typedef  pthread_t PlatformThreadHandle;
const PlatformThreadHandle kNullThreadHandle = 0;
typedef pid_t PlatformThreadId;

class PlatformThread {
public:
    static PlatformThreadId  CurrentId();
    static void YieldCurrentThread();
 private:
    DISALLOW_IMPLICIT_CONSTRUCTORS(PlatformThread);
};
}
#endif
