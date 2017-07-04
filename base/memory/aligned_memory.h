#ifndef BASE_MEMORY_ALIGNED_MEMORY_H_
#define BASE_MEMORY_ALIGNED_MEMORY_H_
#pragma once



#include "basic/basictypes.h"

#define ALIGNAS(byte_alignment) __attribute__((aligned(byte_alignment)))

namespace base {

template <size_t Size, size_t ByteAlignment>
struct AlignedMemory {};

#define BASE_DECL_ALIGNED_MEMORY(byte_alignment) \
    template <size_t Size> \
    class AlignedMemory<Size, byte_alignment> { \
        public: \
            ALIGNAS(byte_alignment) uint8 data_[Size]; \
            void* void_data() { \
                return reinterpret_cast<void*>(data_); \
            } \
            const void* void_data() const { \
                return reinterpret_cast<const void*>(data_); \
            } \
            template<typename Type> \
            Type* data_as() {return reinterpret_cast<Type*>(void_data());} \
            template<typename Type> \
            const Type* data_as() const { \
                return reinterpret_cast<const Type*>(void_data()); \
            } \
        private: \
            void* operator new(size_t); \
            void operator delete(void*); \
    } \

BASE_DECL_ALIGNED_MEMORY(1);
BASE_DECL_ALIGNED_MEMORY(2);
BASE_DECL_ALIGNED_MEMORY(4);
BASE_DECL_ALIGNED_MEMORY(8);
BASE_DECL_ALIGNED_MEMORY(16);
BASE_DECL_ALIGNED_MEMORY(32);
BASE_DECL_ALIGNED_MEMORY(64);
BASE_DECL_ALIGNED_MEMORY(128);
BASE_DECL_ALIGNED_MEMORY(256);
BASE_DECL_ALIGNED_MEMORY(512);
BASE_DECL_ALIGNED_MEMORY(1024);
BASE_DECL_ALIGNED_MEMORY(2048);
BASE_DECL_ALIGNED_MEMORY(4096);
}



#endif
