//
//  BleOTAUtils.h
//  itest
//
//  Created by fby on 2021/10/29.
//

#import <Foundation/Foundation.h>
#import "OTAMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    AckAccept = 0x0000,
    AckRefuse = 0x0001
}CommandAck;

@interface BleOTAUtils : NSObject

+ (NSArray<NSData *> *)generateSectors:(NSData *)bin;

+ (NSData *)generateBinPakcet:(Byte *)data dataLength:(NSUInteger)dataLength index:(NSUInteger)index sequence:(int)sequence crc:(UInt16)crc;

+ (NSData *)generateStartCommandPacket:(NSUInteger)binSize;

+ (NSData *)generateEndCommandPacket;

+ (OTAMessage *)parseCommandPacket:(NSData *)data checksum:(BOOL)checksum;

+ (OTAMessage *)parseBinAckPacket:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
