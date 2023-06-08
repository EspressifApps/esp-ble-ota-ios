//
//  EspCRC16.m
//  itest
//
//  Created by fby on 2021/10/29.
//

#import "EspCRC16.h"

@implementation EspCRC16

+ (UInt16)crc:(NSData *)data {
    return [EspCRC16 crc:data offset:0 length:data.length];
}

+ (UInt16)crc:(NSData *)data offset:(NSUInteger)offset length:(NSUInteger)length {
    UInt16 crc16 = 0;
    Byte *bytes = (Byte *)[data bytes];
    for (NSUInteger cur = offset; cur < length; ++cur) {
        Byte a = bytes[cur];
        crc16 ^= a << 8;
        for (int i = 0; i < 8; ++i) {
            if ((crc16 & 0x8000) != 0) {
                crc16 = (crc16 << 1) ^ 0x1021;
            } else {
                crc16 = crc16 << 1;
            }
        }
    }
    
    return crc16;
}

@end
