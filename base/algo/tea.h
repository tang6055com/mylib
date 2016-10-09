// Copyright (c) 2015-2015 The restful Authors. All rights reserved.
// Created on: 2015/11/24 Author: jiaoyongqing

#ifndef _BASE_ALGO_TEA_H_
#define _BASE_ALGO_TEA_H_

#include "basic/basictypes.h"
#include <stdint.h>

#include <string>
#include <iostream>

struct algo_tea_data {
  void *d;
  size_t l;
};


namespace algo {

bool Encrypt(struct algo_tea_data * td);

bool Decrypt(struct algo_tea_data *td);

}

#endif  //  _ARITHMETIC_TEA_TEA_H_
