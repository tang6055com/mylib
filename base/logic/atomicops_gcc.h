#ifndef LOGIC_ATOMICOPS_GCC_H_
#define LOGIC_ATOMICOPS_GCC_H_
#pragma once


struct AtomicOps_x86CPUFeatureStruct {
    bool has_amd_lock_mb_bug;
    bool has_sse2;
};

extern struct AtomicOps_x86CPUFeatureStruct
    AtomicOps_Internalx86CPUFeatures;

#define ATOMICOPS_COMPILER_BARRIER() __asm__ __volatile__("" : : : "memory")
namespace base {
namespace subtle {

inline void MemoryBarrier() {
    __asm__ __volatile__("mfence" : : : "memory");
}

inline Atomic64 NoBarrier_CompareAndSwap(volatile Atomic64* ptr,
                Atomic64 old_value, Atomic64 new_value) {
    
    Atomic64 prev;
    __asm__ __volatile__("lock; cmpxchgq %1,%2"
                        : "=a" (prev)
                        : "q" (new_value), "m" (*ptr), "0" (old_value)
                        : "memory");
    return prev;
}

inline Atomic64 NoBarrier_AtomicExchange(volatile Atomic64* ptr,
                                         Atomic64 new_value) {
    __asm__ __volatile__("xchgq %1,%0"  // The lock prefix is implicit for xchg.
                        : "=r" (new_value)
                        : "m" (*ptr), "0" (new_value)
                        : "memory");
    return new_value;  // Now it's the previous value.
}

inline Atomic64 NoBarrier_AtomicIncrement(volatile Atomic64* ptr,
                                          Atomic64 increment) {
    Atomic64 temp = increment;
    __asm__ __volatile__("lock; xaddq %0,%1"
                        : "+r" (temp), "+m" (*ptr)
                        : : "memory");
    // temp now contains the previous value of *ptr
    return temp + increment;
}

inline Atomic64 Barrier_AtomicIncrement(volatile Atomic64* ptr,
                                        Atomic64 increment) {
    Atomic64 temp = increment;
    __asm__ __volatile__("lock; xaddq %0,%1"
                        : "+r" (temp), "+m" (*ptr)
                        : : "memory");
          // temp now contains the previous value of *ptr
    if (AtomicOps_Internalx86CPUFeatures.has_amd_lock_mb_bug) {
        __asm__ __volatile__("lfence" : : : "memory");
    }
    return temp + increment;
}

inline void NoBarrier_Store(volatile Atomic64* ptr, Atomic64 value) {
    *ptr = value;
}

inline void Acquire_Store(volatile Atomic64* ptr, Atomic64 value) {
    *ptr = value;
    MemoryBarrier();
}

inline void Release_Store(volatile Atomic64* ptr, Atomic64 value) {
    ATOMICOPS_COMPILER_BARRIER();
    *ptr = value;
}

inline Atomic64 NoBarrier_Load(volatile const Atomic64* ptr) {
    return *ptr;
}

inline Atomic64 Acquire_Load(volatile const Atomic64* ptr) {
    Atomic64 value = *ptr;
    ATOMICOPS_COMPILER_BARRIER();
    return value;
}

inline Atomic64 Release_Load(volatile const Atomic64* ptr) {
    MemoryBarrier();
    return *ptr;
}

inline Atomic64 Acquire_CompareAndSwap(volatile Atomic64* ptr,
                                       Atomic64 old_value,
                                    Atomic64 new_value) {
    Atomic64 x = NoBarrier_CompareAndSwap(ptr, old_value, new_value);
    if (AtomicOps_Internalx86CPUFeatures.has_amd_lock_mb_bug) {
        __asm__ __volatile__("lfence" : : : "memory");
    }
    return x;
}

inline Atomic64 Release_CompareAndSwap(volatile Atomic64* ptr,
                                       Atomic64 old_value,
                                       Atomic64 new_value) {
    return NoBarrier_CompareAndSwap(ptr, old_value, new_value);
}


}   

}
#undef ATOMICOPS_COMPILER_BARRIER
#endif
