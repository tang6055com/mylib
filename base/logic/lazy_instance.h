#ifndef BASE_LOGIC_LAZY_INSTANCE_H_
#define BASE_LOGIC_LAZY_INSTANCE_H_
#pragma once

#include <new>
#include "build/build_config.h"
#include "build/compiler.h"
#include "basic/basictypes.h"
#include "logic/atomicops.h"
#include "memory/aligned_memory.h"
#include "third/dynamic_annotations/dynamic_annotations.h"
#define LAZY_INSTANCE_INITIALIZER {0}

namespace base {
template <typename Type>
struct DefaultLazyInstanceTraits {
    static const bool kRegisterOnExit = true;
    static const bool kAllowedToAccessOnNonjoinableThread = false;
    static Type* New(void* instance) {
        return new (instance) Type();
    }
    static void Delete(Type* instance) {
        instance->~Type();
    }
};

namespace internal {
template  <typename Type>
struct LeakyLazyInstanceTraits {
    static const bool kRegisterOnExit = false;
    static const bool kAllowedToAccessOnNonjoinableThread = true;
    static Type* New(void* instance) {
        return DefaultLazyInstanceTraits<Type>::New(instance);
    }
    static void Delete(Type* instance) {
    }
};
static const subtle::AtomicWord kLazyInstanceStateCreating = 1;

bool NeedsLazyInstance(subtle::AtomicWord* state);

void CompleteLazyInstance(subtle::AtomicWord* state, subtle::AtomicWord new_instance,
                          void* lazy_instance, void (*dtor)(void*));
}// internal



template<typename Type, typename Traits = DefaultLazyInstanceTraits<Type> >
class LazyInstance {
public:
    typedef LazyInstance<Type, internal::LeakyLazyInstanceTraits<Type> > Leaky;

    Type& Get() {
        return * Pointer();
    }

    Type* Pointer() {
#ifndef _DEBUG
        if (!Traits::kAllowedToAccessOnNonjoinableThread)
            ThreadRestrictions::AssertSingletonAllowed();
#endif
        static const subtle::AtomicWord kLazyInstanceCreatedMask =
                    ~internal::kLazyInstanceStateCreating;
        subtle::AtomicWord value = subtle::Acquire_Load(&private_instance_);
        if (!(value & kLazyInstanceCreatedMask) &&
            internal::NeedsLazyInstance(&private_instance_)) {
            value = reinterpret_cast<subtle::AtomicWord>(
                    Traits::New(private_buf_.void_data()));
            internal::CompleteLazyInstance(&private_instance_, value, this,
                            Traits::kRegisterOnExit ? OnExit : NULL);
        }
        ANNOTATE_HAPPENS_AFTER(&private_instance_);
        return instance();
    }

    bool operator==(Type* p) {
        switch (subtle::NoBarrier_Load(&private_instance_)) {
        case 0:
            return p == NULL;
        case internal::kLazyInstanceStateCreating:
            return static_cast<void*>(p) == private_buf_.void_data();
        default:
            return p == instance();
        }
    }

    subtle::AtomicWord private_instance_;
    // Preallocated space for the Type instance.
    base::AlignedMemory<sizeof(Type), ALIGNOF(Type)> private_buf_;

private:
    Type* instance() {
        return reinterpret_cast<Type*>(subtle::NoBarrier_Load(&private_instance_));
    }

    static void OnExit(void* lazy_instance) {
        LazyInstance<Type, Traits>* me =
            reinterpret_cast<LazyInstance<Type, Traits>*>(lazy_instance);
        Traits::Delete(me->instance());
        subtle::NoBarrier_Store(&me->private_instance_, 0);
    }
};


}

#endif
