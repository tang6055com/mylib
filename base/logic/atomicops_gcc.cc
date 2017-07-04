#include <string.h>
#include "logic/atomicops.h"
#include "basic/basictypes.h"

#ifdef  BASE_ATOMICOPS_INTERNALS_X86_GCC_H_
#if defined(__i386__)
#define cpuid(a, b, c, d, inp) \
    asm ("mov %%ebx, %%edi\n"    \
        "cpuid\n"               \
        "xchg %%edi, %%ebx\n"   \
        : "=a" (a), "=D" (b), "=c" (c), "=d" (d) : "a" (inp))
#elif defined (__x86_64__)
#define cpuid(a, b, c, d, inp) \
    asm ("mov %%rbx, %%rdi\n"    \
        "cpuid\n"               \
        "xchg %%rdi, %%rbx\n"   \
        : "=a" (a), "=D" (b), "=c" (c), "=d" (d) : "a" (inp))
#endif

#if defined(cpuid)

struct AtomicOps_x86CPUFeatureStruct AtomicOps_Internalx86CPUFeatures = {false,false,};

static void AtomicOps_Internalx86CPUFeaturesInit() {
    uint32 eax;
    uint32 ebx;
    uint32 ecx;
    uint32 edx;

    cpuid(eax, ebx, ecx, edx, 0);
    char vendor[13];
    memcpy(vendor, &ebx, 4);
    memcpy(vendor + 4, &edx, 4);
    memcpy(vendor + 8, &ecx, 4);
    vendor[12] = 0;

    cpuid(eax, ebx, ecx, edx, 1);

    int family = (eax >> 8) & 0xf;
    int model = (eax >> 4) & 0xf;
    if (family == 0xf) {
        family += (eax >> 20) & 0xff;
        model += ((eax >> 16) & 0xf) << 4;
    }

    if (strcmp(vendor, "AuthenticAMD") == 0 &&
            family == 15 &&
            32 <= model && model <= 63) {
        AtomicOps_Internalx86CPUFeatures.has_amd_lock_mb_bug = true;
    } else {
        AtomicOps_Internalx86CPUFeatures.has_amd_lock_mb_bug = false;
    }

    AtomicOps_Internalx86CPUFeatures.has_sse2 = ((edx >> 26) & 1);
}

namespace {

class AtomicOpsx86Initializer {
public:
    AtomicOpsx86Initializer() {
        AtomicOps_Internalx86CPUFeaturesInit();
    }
};
AtomicOpsx86Initializer g_initer;

}

#endif // if x86
#endif // BASE_ATOMICOPS_INTERNALS_X86_GCC_H_
