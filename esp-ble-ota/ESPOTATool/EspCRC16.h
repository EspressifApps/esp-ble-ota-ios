//
//  EspCRC16.h
//  itest
//
//  Created by fby on 2021/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EspCRC16 : NSObject

+ (UInt16)crc:(NSData *)data;

+ (UInt16)crc:(NSData *)data offset:(NSUInteger)offset length:(NSUInteger)length;

@end

NS_ASSUME_NONNULL_END
