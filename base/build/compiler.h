#ifndef BASE_BUILD_COMPILER_H_
#define BASE_BUILD_COMPILER_H_

#include "build/compiler.h"
// Specify memory alignment for structs, classes, etc.
// Use like:
//   class ALIGNAS(16) MyClass { ... }
//   ALIGNAS(16) int array[4];

#if defined(COMPILER_MSVC)
#define ALIGNOF(type) __alignof(type)
#elif defined(COMPILER_GCC)
#define ALIGNOF(type) __alignof__(type)
#endif

#endif

