// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


#include "logic/lazy_instance.h"
#include "synchronization/lock.h"
#include <assert.h>
static base::LazyInstance<base::Lock>::Leaky
    dtoa_lock_0 = LAZY_INSTANCE_INITIALIZER;

static base::LazyInstance<base::Lock>::Leaky
    dtoa_lock_1 = LAZY_INSTANCE_INITIALIZER;

#define MULTIPLE_THREADS

inline static void ACQUIRE_DTOA_LOCK(size_t n) {
    assert(n < 2);  
    base::Lock* lock = n == 0 ? dtoa_lock_0.Pointer() : dtoa_lock_1.Pointer();
    lock->Acquire();
}

inline static void FREE_DTOA_LOCK(size_t n) {
    assert(n < 2);
    base::Lock* lock = n == 0 ? dtoa_lock_0.Pointer():dtoa_lock_1.Pointer();
    lock->Release();
}

#include "third/dmg_fp/dtoa.cc"
