#ifndef BASE_LOGIC_ATOMICOPS_H_
#define BASE_LOGIC_ATOMICOPS_H_

#include "basic/basictypes.h"
#include "build/build_config.h"
#include <stdint.h>

namespace base {
namespace subtle{
typedef int32 Atomic32;
#ifdef ARCH_CPU_64_BITS
#if defined(OS_NACL)
typedef int64_t Atomic64;
#else
typedef intptr_t Atomic64;
#endif
#endif

typedef intptr_t AtomicWord;


#ifdef ARCH_CPU_64_BITS
Atomic64 NoBarrier_CompareAndSwap(volatile Atomic64* ptr,
                                 Atomic64 old_value,
                                 Atomic64 new_value);

Atomic64 NoBarrier_AtomicExchange(volatile Atomic64* ptr, Atomic64 new_value);
Atomic64 NoBarrier_AtomicIncrement(volatile Atomic64* ptr, Atomic64 increment);

Atomic64 Barrier_AtomicIncrement(volatile Atomic64* ptr, Atomic64 increment);
Atomic64 Acquire_CompareAndSwap(volatile Atomic64* ptr,
                                Atomic64 old_value,
                               Atomic64 new_value);

Atomic64 Release_CompareAndSwap(volatile Atomic64* ptr,
                               Atomic64 old_value,
                               Atomic64 new_value);

void NoBarrier_Store(volatile Atomic64* ptr, Atomic64 value);
void Acquire_Store(volatile Atomic64* ptr, Atomic64 value);
void Release_Store(volatile Atomic64* ptr, Atomic64 value);
Atomic64 NoBarrier_Load(volatile const Atomic64* ptr);
Atomic64 Acquire_Load(volatile const Atomic64* ptr);
Atomic64 Release_Load(volatile const Atomic64* ptr);

#endif
}

}


#if defined(COMPILER_GCC) && defined(ARCH_CPU_X86_FAMILY)
#include "logic/atomicops_gcc.h"
#endif
#endif
