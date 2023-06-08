//
//  ESPFBYBLEHelper.h
//  ESPMeshLibrary
//
//  Created by fanbaoying on 2018/12/20.
//  Copyright © 2018年 fby. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ESPBLEIO.h"
#import "EspDevice.h"
#import "ESPFBYBLEIO.h"

@protocol ESPFBYBleNotifyDelegate <NSObject>

- (void)bleDisconnectMsg:(BOOL)isConnected;

@optional
- (void)bleCharacteristicNotifyMsg:(CBCharacteristic *)characteristic;
- (void)bleDescriptorNotifyMsg:(CBDescriptor *)descriptor;

@end

@interface ESPFBYBLEHelper : NSObject

typedef void(^FBYBleDeviceBackBlock)(EspDevice *device);

@property (nonatomic, copy) FBYBleDeviceBackBlock bleScanSuccessBlock;
@property (weak, nonatomic)id<ESPFBYBleNotifyDelegate> delegate;

/**
 * 单例构造方法
 * @return ESPFBYLocalAPI共享实例
 */
+ (instancetype)share;

//停止扫描
- (void)stopDeviceScan;
//开始扫描
- (void)startScan:(FBYBleDeviceBackBlock)device;
// 断开所有设备连接
- (void)disconnect;
// 断开单个设备连接
- (void)disconnect:(EspDevice *)device;
//开始连接
- (void)connectBle:(EspDevice *)device callBackBlock:(BLEEncryptionSucBackBlock)BleCallBackBlock;

@end

