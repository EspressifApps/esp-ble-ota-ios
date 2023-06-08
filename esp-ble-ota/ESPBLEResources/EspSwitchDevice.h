//
//  EspSwitchDevices.h
//  LightDemon
//
//  Created by fanbaoying on 2019/10/29.
//  Copyright © 2019 fby. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import "EspDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface EspSwitchDevice : NSObject

typedef void(^BLEIOCallBackBlock)(NSString *msg);
typedef void(^BLEEncryptionSucBackBlock)(NSString *msg, EspDevice *encryptionSucDevice);

@property(nonatomic, strong) EspDevice *espDevice;
@property(nonatomic, assign) CBPeripheral *currPeripheral;
@property(nonatomic, strong, nullable) CBCharacteristic* readCharacteristic;
@property(nonatomic, strong, nullable) CBCharacteristic* writeCharacteristic;
@property(nonatomic, strong, nullable) CBDescriptor *descriptor;

@property(nonatomic,assign) BOOL HasSendNegotiateDataWithNewDevice;
@property(nonatomic,assign) uint8_t channel;
@property(nonatomic, strong, nullable)NSMutableData *ESP32data;
@property(nonatomic, assign)NSInteger length;
@property(nonatomic,assign) BOOL isConnected;

@property(nonatomic, strong)NSMutableArray *sendTypeArr;
@property(nonatomic, strong)NSMutableArray *sendLengthArr;
@property(nonatomic, strong, nullable)NSTimer* outTimer;
@property(nonatomic, strong)NSDictionary *infoDic;
@property(nonatomic, strong)NSData* whiteList;
@property(nonatomic, strong)NSData* meshID;

@property (nonatomic, copy) BLEEncryptionSucBackBlock BleCallBackBlock;
@property (nonatomic, copy) BLEIOCallBackBlock CallBackBlock;

@end

NS_ASSUME_NONNULL_END
