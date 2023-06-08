//
//  ViewController.m
//  ESPBluetoothDemo
//
//  Created by fanbaoying on 2019/10/31.
//  Copyright © 2019 fby. All rights reserved.
//

#import "ViewController.h"
#import "ESPFBYBLEHelper.h"
#import "payFirstNav.h"
#import "ESPFBYBLEIO.h"
#import "BleOTAUtils.h"
#import "EspCRC16.h"
#import "SVProgressHUD.h"
    
typedef enum _RemindMessageType {
    defaultType = 0,          //默认
    hiddenImage,
    SuccessType,               //成功
    ErrorType,                //错误
}RemindMessageType;

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ESPFBYBleNotifyDelegate>

@property(strong, nonatomic)UIActivityIndicatorView *progressView;
@property (nonatomic, strong) ESPFBYBLEHelper *espFBYBleHelper;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *espBleDeviceTableView;
@property (nonatomic, assign) BOOL isScanDevice;

@property (strong, nonatomic) payFirstNav *nav;

@property(strong, nonatomic)UITextField *readTimeoutTextField;
@property(strong, nonatomic)UIView *keyboardview;
@property(strong, nonatomic)EspDevice *device;

@property(strong, nonatomic)NSData *binData;
@property(strong, nonatomic)NSMutableArray *binSectors;
@property(nonatomic, assign)NSUInteger sectorIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    self.binSectors = [NSMutableArray arrayWithCapacity:0];
    
    self.nav = [[payFirstNav alloc]initWithLeftBtn:nil andWithTitleLab:@"主页" andWithRightBtn:@"扫描" andWithBgImg:nil];
    [_nav.rightBtn addTarget:self action:@selector(navRightBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nav];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    UILabel *versionLab = [[UILabel alloc]initWithFrame:CGRectMake(10, statusHeight + 44, SCREEN_WIDTH - 20, 15)];
    versionLab.text = [NSString stringWithFormat:@"当前版本：%@", app_Version];
    [self.view addSubview:versionLab];
    
    self.espBleDeviceTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, statusHeight + 65, SCREEN_WIDTH, SCREEN_HEIGHT - (statusHeight + 65))];
    self.espBleDeviceTableView.delegate = self;
    self.espBleDeviceTableView.dataSource = self;
    self.espBleDeviceTableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_espBleDeviceTableView];
    
    self.keyboardview = [[UIView alloc]initWithFrame:CGRectMake(0, statusHeight + 90, SCREEN_WIDTH, SCREEN_HEIGHT - (statusHeight + 100))];
    self.keyboardview.backgroundColor = UICOLOR_RGBA(26, 26, 26, 0.1);
    self.keyboardview.hidden = YES;
    [self.view addSubview:_keyboardview];
    
    self.progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleMedium)];
    self.progressView.frame = CGRectMake(SCREEN_WIDTH / 2 - 50, SCREEN_HEIGHT / 2 - 50, 100, 100);
    self.progressView.color = [UIColor redColor];
    self.progressView.backgroundColor = UICOLOR_RGBA(236, 236, 236, 1);;
    [self.view addSubview:self.progressView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.espFBYBleHelper = [ESPFBYBLEHelper share];
    self.espFBYBleHelper.delegate = self;
    NSLog(@"self.espFBYBleHelper1%@",self.espFBYBleHelper);
    // 进入页面自动扫描
//    [self startDeviceScan];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.espBleDeviceTableView reloadData];
    });
}

- (void)navRightBtn:(UIButton *)sender {
    if (_isScanDevice) {
        NSLog(@"停止扫描");
        _isScanDevice = NO;
        [_nav.rightBtn setTitle:@"扫描" forState:0];
        [self.espFBYBleHelper stopDeviceScan];
    } else {
        _isScanDevice = YES;
        [_nav.rightBtn setTitle:@"停止" forState:0];
        NSLog(@"扫描设备");
//        [self.dataSource removeAllObjects];
        [self startDeviceScan];
    }
}

- (void)showProgress:(BOOL)show {
    if (show) {
        [self.progressView startAnimating];
    } else {
        [self.progressView stopAnimating];
    }
}

- (void)alterMessage:(NSString *)msgStr {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msgStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startDeviceScan {
    [self.espFBYBleHelper startScan:^(EspDevice *device) {
        if (![self isAlreadyExist:device.uuidBle BLEDeviceArray:self.dataSource]) {
            [self.dataSource addObject:device];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.espBleDeviceTableView reloadData];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if (!ValidArray(_dataSource)) {
        return cell;
    }
    EspDevice *device = [self.dataSource objectAtIndex:indexPath.row];
    
    cell.accessibilityIdentifier = device.name;
    
    UILabel *nameLab = [[UILabel alloc] init];
    nameLab.frame = CGRectMake(15, 10, CGRectGetWidth(tableView.frame), 40);
    NSString *deviceInfo = [NSString stringWithFormat:@"Name: %@    RSSI: %d",device.name,device.RSSI];
    nameLab.text = deviceInfo;
    nameLab.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:nameLab];
    
    UILabel *reminderLab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 30, 85, 20)];
    reminderLab.textAlignment = NSTextAlignmentRight;
    reminderLab.font = [UIFont systemFontOfSize:12];
    if (device.isConnected) {
        reminderLab.textColor = UICOLOR_RGBA(39, 158, 242, 1);
        reminderLab.text = @"connect";
    }else {
        reminderLab.textColor = [UIColor redColor];
        reminderLab.text = @"disconnect";
    }
    [cell.contentView addSubview:reminderLab];
    
    UILabel *uuidLab = [[UILabel alloc] init];
    uuidLab.frame = CGRectMake(15, 45,CGRectGetWidth(tableView.frame), 20);
    uuidLab.text = device.uuidBle;
    uuidLab.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:uuidLab];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!ValidArray(_dataSource)) {
        return;
    }
    _isScanDevice = NO;
    [_nav.rightBtn setTitle:@"扫描" forState:0];
    [self.espFBYBleHelper stopDeviceScan];
    EspDevice *device = _dataSource[indexPath.row];
    if (device.isConnected) {
        [self.espFBYBleHelper disconnect];
        self.dataSource = [NSMutableArray arrayWithArray:@[]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.espBleDeviceTableView reloadData];
        });
    }else {
        //连接蓝牙再升级
        __weak typeof(self) weakSelf = self;
        [self.espFBYBleHelper connectBle:device callBackBlock:^(NSString * _Nonnull msg, EspDevice * _Nonnull encryptionSucDevice) {
            NSArray *msgArr = [msg componentsSeparatedByString:@":"];
            if ([msgArr[2] intValue] == FoundCharacteristic) {
                NSLog(@"连接过程返回数据 %@",msg);
                weakSelf.device.isConnected = YES;
                weakSelf.device = encryptionSucDevice;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.espBleDeviceTableView reloadData];
                });
                [weakSelf getDocBinFile];
            }
        }];
    }
}

- (void)initBinData:(NSData *)bin {
    self.binData = bin;
    
    [self.binSectors removeAllObjects];
    [self.binSectors addObjectsFromArray:[BleOTAUtils generateSectors:bin]];
    self.sectorIndex = 0;
}

- (void)ota {
    if (self.sectorIndex < self.binSectors.count) {
        NSData *sector = self.binSectors[self.sectorIndex];
        [self sendMsgWithSector:sector SectorIndex:self.sectorIndex];
    } else {
        NSData *endCommand = [BleOTAUtils generateEndCommandPacket];
        [self.device.currPeripheral writeValue:endCommand forCharacteristic:self.device.charCommand type:0];
    }
}

- (void)getDocBinFile {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    if (!ValidArray(files)) {
        [self remindMessage:@"升级文件不存在" withType:hiddenImage];
        return;
    }
    path = [path stringByAppendingPathComponent:files[0]];
    NSLog(@"file path:%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    if (!isExist) {
        [self remindMessage:@"升级文件路径错误" withType:hiddenImage];
        return;
    }
    NSData *data =[NSData dataWithContentsOfFile:path];
    NSLog(@"获取到的data：%@",data);
    
    [self showProgress:YES];
    
    [self.device.currPeripheral writeValue:[BleOTAUtils generateStartCommandPacket:data.length] forCharacteristic:self.device.charCommand type:CBCharacteristicWriteWithResponse];
    
    [self initBinData:data];
}

- (void)bleCharacteristicNotifyMsg:(CBCharacteristic *)characteristic {
    if (characteristic == self.device.charCommand) {
        OTAMessage *message = [BleOTAUtils parseCommandPacket:characteristic.value checksum:false];
        NSLog(@"message id=%d, status=%d", message.mid, message.status);
        switch (message.mid) {
            case COMMAND_ID_START:
                if (message.status == AckAccept) {
                    // start post bin
                    [self ota];
                } else {
                    // failed
                    NSLog(@"ota COMMAND_ID_START failed");
                    [self showProgress:NO];
                    [self alterMessage:@"配网失败"];
                }
                break;
            case COMMAND_ID_END:
                if (message.status == AckAccept) {
                    // ota complete
                    [self.espFBYBleHelper disconnect:_device];
                    [self showProgress:NO];
                    NSLog(@"ota complete");
                    [self alterMessage:@"配网成功"];
                } else {
                    // failed
                    NSLog(@"ota COMMAND_ID_END failed");
                    [self showProgress:NO];
                    [self alterMessage:@"配网失败"];
                }
                break;
            default:
                break;
        }
    } else if (characteristic == self.device.charRecvFW) {
        OTAMessage *message = [BleOTAUtils parseBinAckPacket:characteristic.value];
        if (message.index != self.sectorIndex) {
            NSLog(@"ota bin ack index failed");
            [self showProgress:NO];
            [self alterMessage:@"配网失败"];
            return;
        }
        
        switch (message.status) {
            case BIN_ACK_SUCCESS:
                self.sectorIndex++;
                [self ota];
                break;
            default:
                // OTA failed
                NSLog(@"ota bin ack failed status: %d", message.status);
                [self showProgress:NO];
                [self alterMessage:@"配网失败"];
                break;
        }
    }
    
}
- (void)bleDisconnectMsg:(BOOL)isConnected {
    NSLog(@"蓝牙断开连接");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.espBleDeviceTableView reloadData];
    });
}

//分包发送蓝牙数据
-(void)sendMsgWithSector:(NSData*)sector
                 SectorIndex:(NSUInteger)index
{
    UInt16 crc = 0;
    int sequence = 0;
    Byte buf[BLE_SEND_MAX_LEN];
    NSInputStream *stream = [[NSInputStream alloc] initWithData:sector];
    [stream open];
    while (stream.hasBytesAvailable) {
        NSUInteger read = [stream read:buf maxLength:BLE_SEND_MAX_LEN];
        if (!stream.hasBytesAvailable) {
            crc = [EspCRC16 crc:sector];
            sequence = -1;
        }
        NSData *binPacket = [BleOTAUtils generateBinPakcet: buf dataLength:read index:index sequence:sequence crc:crc];
        ++sequence;
        [self.device.currPeripheral writeValue:binPacket forCharacteristic:self.device.charRecvFW type:CBCharacteristicWriteWithResponse];
    }
    [stream close];
    
}

- (BOOL)isAlreadyExist:(NSString *)deviceMac BLEDeviceArray:(NSMutableArray *)array {
    for (int i = 0; i < array.count; i++) {
        EspDevice *device = array[i];
        if ([deviceMac isEqualToString:device.uuidBle]) {
            return YES;
        }
    }
    return NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.espFBYBleHelper stopDeviceScan];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.keyboardview.hidden = NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.keyboardview.hidden = YES;
}

- (void)remindMessage:(NSString *)message withType:(RemindMessageType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type == defaultType) {
            [SVProgressHUD showWithStatus:NSLocalizedString(message, nil)];
        } else if (type == hiddenImage) {
            [SVProgressHUD showImage:[UIImage imageNamed:@""] status:NSLocalizedString(message, nil)];
        } else if (type == SuccessType) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(message, nil)];
        } else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(message, nil)];
        }
        [SVProgressHUD dismissWithDelay:2];
    });
}

@end

