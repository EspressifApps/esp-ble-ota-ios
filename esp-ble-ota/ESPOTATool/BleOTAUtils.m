//
//  BleOTAUtils.m
//  itest
//
//  Created by fby on 2021/10/29.
//

#import "BleOTAUtils.h"
#import "EspCRC16.h"

@implementation BleOTAUtils

+ (NSArray<NSData *> *)generateSectors:(NSData *)bin {
    NSMutableArray<NSData *> *sectors = [[NSMutableArray alloc] init];
    NSInputStream *stream = [[NSInputStream alloc] initWithData:bin];
    uint8_t buf[4096];
    [stream open];
    while ([stream hasBytesAvailable]) {
        NSUInteger read = [stream read:buf maxLength:4096];
        NSData *sector = [[NSData alloc] initWithBytes:buf length:read];
        [sectors addObject:sector];
    }
    [stream close];
    
    return sectors;
}

+ (NSData *)generateBinPakcet:(Byte *)data dataLength:(NSUInteger)dataLength index:(NSUInteger)index sequence:(int)sequence crc:(UInt16)crc {
    NSMutableData *packet = [[NSMutableData alloc] init];
    Byte buf[3] = {
        index & 0xff,
        index >> 8 & 0xff,
        sequence & 0xff
    };
    [packet appendBytes:buf length:3];
    [packet appendBytes:data length:dataLength];
    if (sequence < 0) {
        Byte crcBytes[2] = {
            crc & 0xff,
            crc >> 8 & 0xff
        };
        [packet appendBytes:crcBytes length:2];
    }
    
    return packet;
}

+ (NSData *)generateCommandPacket:(int)commandId payload:(NSData *)payload {
    NSMutableData *packet = [[NSMutableData alloc] init];
    Byte idBytes[2] = {
        commandId & 0xff,
        commandId >> 8 & 0xff
    };
    [packet appendBytes:idBytes length:2];
    [packet appendData:payload];
    NSUInteger paddingLen = 18 - packet.length;
    if (paddingLen > 0) {
        NSData *padding = [[NSMutableData alloc] initWithLength:paddingLen];
        [packet appendData:padding];
    }
    UInt16 crc = [EspCRC16 crc:packet];
    Byte crcBytes[2] = {
        crc & 0xff,
        crc >> 8 & 0xff
    };
    [packet appendBytes:crcBytes length:2];
    
    return packet;
}

+ (NSData *)generateStartCommandPacket:(NSUInteger)binSize {
    Byte bytes[4] = {
        binSize & 0xff,
        binSize >> 8 & 0xff,
        binSize >> 16 & 0xff,
        binSize >> 24 & 0xff
    };
    NSData *payload = [[NSData alloc] initWithBytes:bytes length:4];
    return [BleOTAUtils generateCommandPacket:COMMAND_ID_START payload:payload];
}

+ (NSData *)generateEndCommandPacket {
    NSData *payload = [[NSMutableData alloc] initWithLength:1];
    return [BleOTAUtils generateCommandPacket:COMMAND_ID_END payload:payload];
}

+ (OTAMessage *)parseCommandPacket:(NSData *)data checksum:(BOOL)checksum {
    Byte *bytes = (Byte *)[data bytes];
    if (checksum) {
        UInt16 srcCRC = bytes[18] | (bytes[19] << 8);
        UInt16 calcCRC = [EspCRC16 crc:data offset:0 length:18];
        if (srcCRC != calcCRC) {
            NSLog(@"parseCommandPacket checksum error: %d, expect %d", srcCRC, calcCRC);
            return nil;
        }
    }
    
    int commandId = bytes[0] | (bytes[1] << 8);
    if (commandId == COMMAND_ID_ACK) {
        int ackId = bytes[2] | (bytes[3] << 8);
        int ackStatus = bytes[4] | (bytes[5] << 8);
        return [[OTAMessage alloc] initWithId:ackId status:ackStatus];
    }
    
    return nil;
}

+ (OTAMessage *)parseBinAckPacket:(NSData *)data {
    Byte *bytes = (Byte *)[data bytes];
    int ackIndex = bytes[0] | (bytes[1] << 8);
    int ackStatus = bytes[2] | (bytes[3] << 8);
    OTAMessage *message = [[OTAMessage alloc] initWithId:COMMAND_ID_ACK status:ackStatus];
    message.index = ackIndex;
    return message;
}

@end
