//
//  ESPFBYBLEIO.h
//  LightDemon
//
//  Created by fanbaoying on 2019/11/1.
//  Copyright © 2019 fby. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EspSwitchDevice.h"

NS_ASSUME_NONNULL_BEGIN

enum ConfigureNumber {
    ConfigureSuccessful = 300,          //配网成功
    BleConnectSuccessful,               //蓝牙连接成功
    FoundServices,                      //发现服务
    FoundCharacteristic,                //发现特征
    FoundDescriptors,                    //发现描述
    WriteDataSuccessful,                //写入数据成功
    NotificationSuccessful,             //订阅特征通知
    ControlPacketConfigureData,         //控制包解析数据成功
    NegotiateSecuritykeySuccessful,     //协商加密成功
    DeviceConnectWIFISuccessful,        //设备连接Wi-Fi成功
    PeripheralStateConnected,           //外设连接状态
    NotifyDeviceEncryptionMode,         //加密模式通知
    BleDisconnectSuccessful,            //蓝牙正常断开连接
    CustomDataBlock,                    //发送自定义数据回调
    StartContrastTestData,               //开始对比测试数据
};

enum BleConfigureFailNumber {
    RetrievePeripheralFailed = 9000,    //检索外设失败
    PeripheralStateDisconnected,        //外设断开连接状态
    CentralManagerStatePoweredOff,      //蓝牙关闭
    BleConnectFailed,                   //蓝牙连接失败
    BleAbnormalDisconnect,              //蓝牙异常断开连接
    BleSetNotifyFailed,                 //特征当前正在通知
    NotificationStateFailed,            //订阅特征通知失败
    BleDataCallbackFailed,              //订阅蓝牙设备返回数据失败
    CharacteristicNotifyLimits,         //特征通知限制
    PeripheralWriteCharacteristicNil,   //蓝牙数据发送失败
    CRCFailed,                          //数据校验失败
    AnalyseDataFailed,                  //数据解析失败
    WiFiOpmodeFailed,                   //Wi-Fi Opmode 失败
    DeviceConnectWiFiFailed,            //设备连接Wi-Fi失败
    NotifyDataFailed,                   //设备返回数据错误
};

@interface ESPFBYBLEIO : NSObject

@end

NS_ASSUME_NONNULL_END
