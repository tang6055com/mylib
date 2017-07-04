#include "logic/lazy_instance.h"
#include "thread/platform_thread.h"
namespace base {
namespace internal {

bool NeedsLazyInstance(subtle::AtomicWord* state) {

    if (subtle::NoBarrier_CompareAndSwap(state, 0,
                                         kLazyInstanceStateCreating) == 0)
        return true;

    while (subtle::Acquire_Load(state) == kLazyInstanceStateCreating) {
        PlatformThread::YieldCurrentThread();
    }

    return false;
}


void CompleteLazyInstance(subtle::AtomicWord* state, subtle::AtomicWord new_instance, 
                          void* lazy_instance, void (*dtor)(void*)) {
    ANNOTATE_HAPPENS_BEFORE(state);
    subtle::Release_Store(state, new_instance);
    //Make sure that the lazily instantiated object will get destroyed at exit 
    //chrome放入AtExitManager进行管理，退出时候释放。
}

}

}
