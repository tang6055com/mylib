//  Copyright (c) 2015-2015 The migfm Authors. All rights reserved.
//  Created on: 2015年9月26日 Author: kerry

#ifndef TEA_H_
#define TEA_H_

#include <netinet/in.h>
#include <string>
#include <cmath>
#include <cstdlib>

#include "basic/basictypes.h"

typedef unsigned char byte;
typedef unsigned long ulong;

namespace algorithm {

inline double logbase(double base, double x) {
    return log(x)/log(base);
}

/*
*convert int to hex char.
*example:10 -> 'A',15 -> 'F'
*/
char IntToHexChar(int x);


/*
*convert hex char to int.
*example:'A' -> 10,'F' -> 15
*/
int HexCharToInt(char hex);

/*
*convert a byte array to hex string.
*hex string format example:"AF B0 80 7D"
*/
std::string ByteToHexString(const byte *in, size_t size);

/*
*convert a hex string to a byte array.
*hex string format example:"AF B0 80 7D"
*/
size_t HexStringToByte(const std::string &str, byte *out);


class Tea {
 public:
    Tea(const byte* key, int32 round = 32, bool is_net_byte = false);

    Tea(const Tea& rhs);

    Tea& operator = (const Tea& rhs);

    void encrypt(const byte* in, byte* out);
    void decrypt(const byte* in, byte* out);

 private:
    void encrypt(const ulong* in, ulong* out);
    void decrypt(const ulong* in, ulong* out);
    unsigned long ntoh(ulong netlong) {
        return is_net_char_ ? ntohl(netlong) : netlong;
    }
    unsigned long hton(ulong hostlong) {
        return is_net_char_ ? htonl(hostlong) : hostlong;
    }

 private:
    int32  round_;
    bool   is_net_char_;
    byte   key_[16];
};
}




#endif /* TEA_H_ */
