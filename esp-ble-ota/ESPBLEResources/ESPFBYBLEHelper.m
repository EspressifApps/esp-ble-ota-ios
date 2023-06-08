//
//  ESPFBYBLEHelper.m
//  ESPMeshLibrary
//
//  Created by fanbaoying on 2018/12/20.
//  Copyright © 2018年 fby. All rights reserved.
//

#import "ESPFBYBLEHelper.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import "EspDevice.h"


#define ValidDict(f) (f!=nil && [f isKindOfClass:[NSDictionary class]])

API_AVAILABLE(ios(10.0))
@interface ESPFBYBLEHelper ()<CBCentralManagerDelegate,CBPeripheralDelegate>
// 中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;
// 扫描到的设备
@property (nonatomic, strong) CBPeripheral *cbPeripheral;
// 外设状态
@property (nonatomic, assign) CBManagerState peripheralState;

@property(nonatomic, strong) NSMutableDictionary *scanBleDevicesDic;
@property(nonatomic, strong) NSMutableDictionary *bleDevicesSaveDic;

@property(nonatomic, strong) NSMutableDictionary *bleDevicesSerDic;

@end

@implementation ESPFBYBLEHelper
{
    EspDevice *Device;
}
- (NSMutableArray *)peripherals
{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (void)ESPFBYBLEHelperInit {
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.bleDevicesSaveDic = [NSMutableDictionary dictionaryWithCapacity:0];
    self.scanBleDevicesDic = [NSMutableDictionary dictionaryWithCapacity:0];
    self.bleDevicesSerDic = [NSMutableDictionary dictionaryWithCapacity:0];
}

//单例模式
+ (instancetype)share {
    static ESPFBYBLEHelper *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[ESPFBYBLEHelper alloc]init];
        [share ESPFBYBLEHelperInit];
    });
    return share;
}

- (void)stopDeviceScan {
    [self.centralManager stopScan];
}

- (void)startScan:(FBYBleDeviceBackBlock)device {
    _bleScanSuccessBlock = device;
    if (self.peripheralState ==  CBManagerStatePoweredOn) {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    if (@available(iOS 10.0, *)) {
    } else {
        // Fallback on earlier versions
    }
}

- (void)disconnect {
    [self.peripherals removeAllObjects];
    NSArray *bleValue = _bleDevicesSaveDic.allValues;
    for (int i = 0; i < bleValue.count; i ++) {
        EspSwitchDevice *espSwitchDevice = bleValue[i];
        if (espSwitchDevice.isConnected) {
            // 取消连接
            [self.centralManager cancelPeripheralConnection:espSwitchDevice.currPeripheral];
            espSwitchDevice.isConnected = NO;
            espSwitchDevice.espDevice.isConnected = NO;
        }
    }
}

// 断开单个设备连接
- (void)disconnect:(EspDevice *)device {
    if (device.isConnected) {
        [self.centralManager cancelPeripheralConnection:device.currPeripheral];
    }
}

- (void)connectBle:(EspDevice *)device callBackBlock:(BLEEncryptionSucBackBlock)BleCallBackBlock {
    [self.centralManager stopScan];
    
    EspSwitchDevice *espSwitchDevice = self.bleDevicesSaveDic[device.uuidBle];
    if (espSwitchDevice == nil) {
        espSwitchDevice = [[EspSwitchDevice alloc]init];
        device.charCommand = nil;
        device.charRecvFW = nil;
        espSwitchDevice.espDevice = device;
        espSwitchDevice.isConnected = NO;
        espSwitchDevice.espDevice.isConnected = NO;
        
        self.bleDevicesSaveDic[device.uuidBle] = espSwitchDevice;
    }
    espSwitchDevice.BleCallBackBlock = BleCallBackBlock;
    
    if (!espSwitchDevice.isConnected) {
        espSwitchDevice.currPeripheral = device.currPeripheral;
        self.cbPeripheral = espSwitchDevice.currPeripheral;
        // 设置设备的代理
        self.cbPeripheral.delegate = self;
        
        [self.centralManager connectPeripheral:_cbPeripheral options:nil];
    } else{
        NSLog(@"无设备可连接");
    }
}

// 根据UUID获取外设
- (CBPeripheral *)retrievePeripheralWithUUIDString:(NSString *)UUIDString {
    CBPeripheral *p = nil;
    @try {
        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:UUIDString];
        p = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]][0];
    } @catch (NSException *exception) {
        NSLog(@">>> retrievePeripheralWithUUIDString error:%@",exception);
    } @finally {
    }
    return p;
}

// 状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"为知状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"重置状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"不支持的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"未授权的状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"关闭状态");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"开启状态－可用状态");
            self.peripheralState = central.state;
            NSLog(@"%ld",(long)self.peripheralState);
        }
            break;
        default:
            break;
    }
}

/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    if ([self isNull:name]) {
        return;
    }
    
    EspDevice *device = self.scanBleDevicesDic[peripheral.identifier.UUIDString];
    if (device == nil) {
        device=[[EspDevice alloc] init];
    }
    device.uuidBle = peripheral.identifier.UUIDString;
    device.RSSI = RSSI.intValue;
    device.name = name;
    device.currPeripheral = peripheral;
    
    self.scanBleDevicesDic[peripheral.identifier.UUIDString] = device;
    
    if (_bleScanSuccessBlock) {
        _bleScanSuccessBlock(device);
    }
}

/**
 连接失败
 
 @param central 中心管理者
 @param peripheral 连接失败的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",@"连接失败");
    EspSwitchDevice *espSwitchDevice = self.bleDevicesSaveDic[peripheral.identifier.UUIDString];
    [self bleUpdateMessage:[NSString stringWithFormat:@"bleerror:Ble connect failed:%d:%@",BleConnectFailed, peripheral.identifier.UUIDString] ForDevice:espSwitchDevice];
    espSwitchDevice.isConnected = NO;
    espSwitchDevice.espDevice.isConnected = NO;
}

/**
 连接断开
 
 @param central 中心管理者
 @param peripheral 连接断开的设备
 @param error 错误信息
 */

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    EspSwitchDevice *espSwitchDevice = self.bleDevicesSaveDic[peripheral.identifier.UUIDString];
    NSLog(@"didDisconnectPeripheral: %@",@"断开连接");
    espSwitchDevice.isConnected = NO;
    espSwitchDevice.espDevice.isConnected = NO;
    espSwitchDevice.espDevice.charCommand=nil;
    espSwitchDevice.espDevice.charRecvFW =nil;
    [self.bleDevicesSaveDic removeObjectForKey:peripheral.identifier.UUIDString];
    
    [self.delegate bleDisconnectMsg:NO];
    
    if (error) {
        NSLog(@"蓝牙异常断开：%@",error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BleAbnormalDisconnect" object:nil];
        [self bleUpdateMessage:[NSString stringWithFormat:@"bleerror:Ble abnormal disconnect%@:%d:%@",error,BleAbnormalDisconnect, peripheral.identifier.UUIDString] ForDevice:espSwitchDevice];
    }else {
        [self bleUpdateMessage:[NSString stringWithFormat:@"blemsg:Disconnect successful:%d:%@",BleDisconnectSuccessful, peripheral.identifier.UUIDString] ForDevice:espSwitchDevice];
    }
}

/**
 连接成功
 
 @param central 中心管理者
 @param peripheral 连接成功的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    EspSwitchDevice *espSwitchDevice = self.bleDevicesSaveDic[peripheral.identifier.UUIDString];
    espSwitchDevice.isConnected = YES;
    espSwitchDevice.espDevice.isConnected = YES;
    [self.delegate bleDisconnectMsg:YES];
    [self bleUpdateMessage:[NSString stringWithFormat:@"blemsg:ble connect successful:%d:%@",BleConnectSuccessful,peripheral.identifier.UUIDString] ForDevice:espSwitchDevice];
    NSLog(@"连接设备:%@成功",peripheral.name);
    
    [peripheral discoverServices:nil];
}

/**
 扫描到服务
 
 @param peripheral 服务对应的设备
 @param error 扫描错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"扫描服务出现错误");
    }else {
        EspSwitchDevice *espSwitchDevice = self.bleDevicesSaveDic[peripheral.identifier.UUIDString];
        espSwitchDevice.espDevice.services = peripheral.services;
        [self bleUpdateMessage:[NSString stringWithFormat:@"blemsg:found services:%d:%@",FoundServices, peripheral.identifier.UUIDString] ForDevice:espSwitchDevice];
        // 遍历所有的服务
        for (CBService *service in peripheral.services)
        {
            NSLog(@"服务:%@,name:%@,characteristic:%@",service.UUID.UUIDString, peripheral.name,service.characteristics);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

/**
 扫描到对应的特征
 
 @param peripheral 设备
 @param service 特征对应的服务
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristicsForService: %@", service.UUID.UUIDString);
    EspSwitchDevice *espSwitchDevice = self.bleDevicesSaveDic[peripheral.identifier.UUIDString];
    espSwitchDevice.espDevice.characteristics = service.characteristics;
    
    
    if (![service.UUID.UUIDString isEqualToString:SERVICEUUID]) {
        return;
    }
    if (espSwitchDevice.espDevice.charRecvFW  && espSwitchDevice.espDevice.charCommand) {
        return;
    }
    
    for (CBCharacteristic* characteristic in service.characteristics)
    {
        if ([[[characteristic UUID] UUIDString] isEqualToString:RECV_FW_CHAR])
        {
            espSwitchDevice.espDevice.charRecvFW = characteristic;
        }
        if ([[[characteristic UUID] UUIDString] isEqualToString:COMMAND_CHAR])
        {
            espSwitchDevice.espDevice.charCommand = characteristic;
        }
        NSLog(@"didDiscoverCharacteristicsForService characteristic: %@", characteristic);
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        if (espSwitchDevice.espDevice.charRecvFW  && espSwitchDevice.espDevice.charCommand) {
            [self bleUpdateMessage:[NSString stringWithFormat:@"blemsg:found Characteristic:%d",FoundCharacteristic] ForDevice:espSwitchDevice];
            break;
        }
    }
}

//characteristic订阅状态改变的代理
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        if (characteristic.isNotifying) {
        } else {
            NSLog(@"bleerror:Ble set notify failed:%d:%@",BleSetNotifyFailed, peripheral.identifier.UUIDString);
        }
    } else {
        NSLog(@"bleerror:Notification state failed:%d:%@",NotificationStateFailed, peripheral.identifier.UUIDString);
    }
}

/**
 根据特征读到数据
 
 @param peripheral 读取到数据对应的设备
 @param characteristic 特征
 @param error 错误信息
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        NSLog(@"ser:%@ -- char:%@:读取报错：%@, 报错内容：%@",characteristic.service.UUID.UUIDString, characteristic.UUID.UUIDString, characteristic, error);
        [self.delegate bleCharacteristicNotifyMsg:nil];
        return;
    }
    if ([self isNull:characteristic]) {
        [self.delegate bleCharacteristicNotifyMsg:nil];
        return;
    }
    NSData *data = characteristic.value;
    if ([self isNull:data]) {
        [self.delegate bleCharacteristicNotifyMsg:nil];
        return;
    }
    [self.delegate bleCharacteristicNotifyMsg:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"设备特征UUID = %@ 写入数据失败，失败原因:%@", characteristic.UUID, error);
    }else {
        NSLog(@"设备特征UUID = %@ 写入数据成功", characteristic.UUID);
    }
}

// 回调数据处理
- (void)bleUpdateMessage:(NSString *)message ForDevice:(EspSwitchDevice *)espSwitchDevice {
    if (espSwitchDevice.BleCallBackBlock) {
        espSwitchDevice.BleCallBackBlock(message, espSwitchDevice.espDevice);
    }
}

- (BOOL)isNull:(NSObject *)object {
    if (object == nil ||
        [object isEqual:[NSNull null]] ||
        [object isEqual:@""] ||
        [object isEqual:@" "] ||
        [object isEqual:@"null"] ||
        [object isEqual:@"<null>"] ||
        [object isEqual:@"(null)"] ){
        
        return YES;
    } else {
        return NO;
    }
}
@end
