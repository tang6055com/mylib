#ifndef BUILD_BUILD_CONFIG_H_
#define BUILD_BUILD_CONFIG_H_

#if defined(__APPLE__)
#define OS_MACOSX 1
#elif defined(ANDROID)
#define OS_ANDROID 1
#elif defined(__native_client__)
#define OS_NACL 1
#elif defined(__linux__)
#define OS_LINUX 1
#if !defined(TOOLKIT_VIEWS)
#define TOOLKIT_GTK
#endif
#elif defined(_WIN32)
#define OS_WIN 1
#define TOOLKIT_VIEWS 1
#elif defined(__FreeBSD__)
#define OS_FREEBSD 1
#define TOOLKIT_GTK
#elif defined(__OpenBSD__)
#define OS_OPENBSD 1
#define TOOLKIT_GTK
#elif defined(__sun)
#define OS_SOLARIS 1
#define TOOLKIT_GTK
#else
#error Please add support for your platform in build/build_config.h
#endif

#if defined(_M_X64) || defined(__x86_64__)
#define ARCH_CPU_X86_FAMILY 1
#define ARCH_CPU_X86_64 1
#define ARCH_CPU_64_BITS 1
#define ARCH_CPU_LITTLE_ENDIAN 1
#elif defined(_M_IX86) || defined(__i386__)
#define ARCH_CPU_X86_FAMILY 1
#define ARCH_CPU_X86 1
#define ARCH_CPU_32_BITS 1
#define ARCH_CPU_LITTLE_ENDIAN 1
#elif defined(__ARMEL__)
#define ARCH_CPU_ARM_FAMILY 1
#define ARCH_CPU_ARMEL 1
#define ARCH_CPU_32_BITS 1
#define ARCH_CPU_LITTLE_ENDIAN 1
#define WCHAR_T_IS_UNSIGNED 1
#elif defined(__pnacl__)
#define ARCH_CPU_32_BITS 1
#else
#error Please add support for your architecture in build/build_config.h
#endif


// Compiler detection.
#if defined(__GNUC__)
#define COMPILER_GCC 1
#elif defined(_MSC_VER)
#define COMPILER_MSVC 1
#else
#error Please add support for your compiler in build/build_config.h
#endif

#if defined(OS_MACOSX) || defined(OS_LINUX) || defined(OS_FREEBSD) ||     \
            defined(OS_OPENBSD) || defined(OS_SOLARIS) || defined(OS_ANDROID) ||  \
            defined(OS_NACL)
#define OS_POSIX 1
#endif

#endif 
