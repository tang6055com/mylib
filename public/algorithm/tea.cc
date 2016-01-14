//  Copyright (c) 2015-2015 The migfm Authors. All rights reserved.
//  Created on: 2015年9月26日 Author: kerry


#include "tea.h"
#include <ctype.h>
#include <cstring>
#include <vector>

namespace algorithm {

char IntToHexChar(int x) {

    static const char HEX[16] = {
            '0', '1', '2', '3',
            '4', '5', '6', '7',
            '8', '9', 'A', 'B',
            'C', 'D', 'E', 'F'
    };
    return HEX[x];
}

int HexCharToInt(char hex) {
    hex = toupper(hex);
    if (isdigit(hex))
        return (hex - '0');
    if (isalpha(hex))
        return (hex - 'A' + 10);
    return 0;
}


std::string ByteToHexString(const byte *in, size_t size) {
    std::string str;
    for (size_t i = 0; i < size; ++i) {
        int t = in[i];
        int a = t / 16;
        int b = t % 16;
        str.append(1, IntToHexChar(a));
        str.append(1, IntToHexChar(b));
        if (i != size - 1)
            str.append(1, ' ');
    }
    return str;
}

size_t HexStringToByte(const std::string &str, byte *out) {
    std::vector<std::string> vec;
    std::string::size_type currPos = 0, prevPos = 0;
    while ((currPos = str.find(' ', prevPos)) != std::string::npos) {
        std::string b(str.substr(prevPos, currPos - prevPos));
        vec.push_back(b);
        prevPos = currPos + 1;
    }

    if (prevPos < str.size()) {
        std::string b(str.substr(prevPos));
        vec.push_back(b);
    }

    typedef std::vector<std::string>::size_type sz_type;
    sz_type size = vec.size();
    for (sz_type i = 0; i < size; ++i) {
        int a = HexCharToInt(vec[i][0]);
        int b = HexCharToInt(vec[i][1]);
        out[i] = a * 16 + b;
    }
    return size;
}

Tea::Tea(const byte* key, int32 round, bool is_net_char)
:round_(round)
,is_net_char_(is_net_char) {
    if(key != NULL)
        memcpy(key_, key, 16);
    else
        memset(key_, '\0', 16);
}

Tea::Tea(const Tea& rhs)
:round_(rhs.round_)
,is_net_char_(rhs.is_net_char_) {
    memcpy(key_, rhs.key_, 16);
}

Tea& Tea::operator =(const Tea& rhs) {
    if (&rhs != this) {
        round_ = rhs.round_;
        is_net_char_ = rhs.is_net_char_;
        memcpy(key_, rhs.key_, 16);
    }
    return (*this);
}

void Tea::encrypt(const byte* in, byte* out) {
    encrypt((const ulong*)in, (ulong*)out);
}

void Tea::decrypt(const byte* in, byte* out) {
    decrypt((const ulong*)in, (ulong*)out);
}

void Tea::encrypt(const ulong* in, ulong* out) {
    unsigned long *k = (unsigned long*)key_;
    register ulong y = ntoh(in[0]);
    register ulong z = ntoh(in[1]);
    register ulong a = ntoh(k[0]);
    register ulong b = ntoh(k[1]);
    register ulong c = ntoh(k[2]);
    register ulong d = ntoh(k[3]);
    register ulong delta = 0x9E3779B9; /* (sqrt(5)-1)/2*2^32 */
    register int round = round_;
    register ulong sum = 0;

    while (round--) {    /* basic cycle start */
        sum += delta;
        y += ((z << 4) + a) ^ (z + sum) ^ ((z >> 5) + b);
        z += ((y << 4) + c) ^ (y + sum) ^ ((y >> 5) + d);
    }    /* end cycle */
    out[0] = ntoh(y);
    out[1] = ntoh(z);
}

void Tea::decrypt(const ulong* in, ulong* out) {

    ulong *k = (ulong*)key_;
    register ulong y = ntoh(in[0]);
    register ulong z = ntoh(in[1]);
    register ulong a = ntoh(k[0]);
    register ulong b = ntoh(k[1]);
    register ulong c = ntoh(k[2]);
    register ulong d = ntoh(k[3]);
    register ulong delta = 0x9E3779B9; /* (sqrt(5)-1)/2*2^32 */
    register int round = round_;
    register ulong sum = 0;

    if (round == 32)
        sum = 0xC6EF3720; /* delta << 5*/
    else if (round == 16)
        sum = 0xE3779B90; /* delta << 4*/
    else
        sum = delta << static_cast<int>(logbase(2, round));

    while (round--) {    /* basic cycle start */
        z -= ((y << 4) + c) ^ (y + sum) ^ ((y >> 5) + d);
        y -= ((z << 4) + a) ^ (z + sum) ^ ((z >> 5) + b);
        sum -= delta;
    }    /* end cycle */
    out[0] = ntoh(y);
    out[1] = ntoh(z);
}




}

