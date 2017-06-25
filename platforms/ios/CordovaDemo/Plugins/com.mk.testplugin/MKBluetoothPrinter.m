//
//  MKBluetoothPrinter.m
//  CordovaDemo
//
//  Created by xmk on 2017/6/20.
//
//

#import "MKBluetoothPrinter.h"
#import "HLBLEManager.h"
#import "HLPrinter.h"
#import "MKConst.h"
#import "MKPrinterInfoModel.h"

@interface MKBluetoothPrinter ()
@property (nonatomic, strong) HLBLEManager *manager;
@property (nonatomic, strong) NSMutableArray *peripheralsArray;     /*!< 外设列表 */
@property (nonatomic, copy  ) NSString *scanPeripheralsCallBackId;  /*!< 扫描 接口 callBackId, 用于持续回调JS*/
@property (nonatomic, strong) CBPeripheral *connectPeripheral;      /*!< 连接的外设 */
@property (nonatomic, strong) CBCharacteristic *chatacter;          /*!< 可写入数据的特性 */
@property (nonatomic, strong) NSMutableArray *servicesArray;        /*!< 外设 服务列表 */
@property (nonatomic, strong) HLPrinter *printerInfo;               /*!< 打印数据 */
@property (nonatomic, strong) NSMutableArray *printerModelArray;    /*!< 打印信息数组 主要用于排序*/
@end

@implementation MKBluetoothPrinter

#pragma mark - ***** scan peripherals *****
- (void)scanForPeripherals:(CDVInvokedUrlCommand *)command{
    BOOL bKeepCallBack = NO;
    if (command.arguments.count > 0) {
        bKeepCallBack = [command.arguments[0] integerValue] == 1;
    }
    
    self.scanPeripheralsCallBackId = nil;
    self.scanPeripheralsCallBackId = command.callbackId.copy;
    
    __weak HLBLEManager *weakManager = self.manager;
    __weak MKBluetoothPrinter *weakSelf = self;
    
    self.manager.stateUpdateBlock = nil;
    self.manager.stateUpdateBlock = ^(CBCentralManager *central) {
        NSString *info = nil;
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:{
                [weakManager scanForPeripheralsWithServiceUUIDs:nil options:nil didDiscoverPeripheral:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
                    ELog(@"peripheral.name : %@", peripheral.name);
                    if (peripheral.name.length <= 0) {
                        return ;
                    }
                    BOOL isExist = NO;
                    for (int i = 0; i < weakSelf.peripheralsArray.count; i++) {
                        CBPeripheral *per = weakSelf.peripheralsArray[i];
                        ELog(@"UUIDString %zd :%@",i, per.identifier.UUIDString);
                        if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                            isExist = YES;
                            [weakSelf.peripheralsArray replaceObjectAtIndex:i withObject:peripheral];
                            break;
                        }
                    }
                    if (!isExist) {
                        [weakSelf.peripheralsArray addObject:peripheral];
                    }
                    [weakSelf callBackPeripheralsWithKeep:bKeepCallBack];
                    return;
                }];
            }
                return;
            case CBCentralManagerStatePoweredOff:
                info = @"蓝牙可用，未打开";
                break;
            case CBCentralManagerStateUnsupported:
                info = @"SDK不支持";
                break;
            case CBCentralManagerStateUnauthorized:
                info = @"程序未授权";
                break;
            case CBCentralManagerStateResetting:
                info = @"CBCentralManagerStateResetting";
                break;
            case CBCentralManagerStateUnknown:
                info = @"CBCentralManagerStateUnknown";
                break;
            default:
                break;
        }
        [weakSelf callBackSuccess:NO callBackId:command.callbackId message:info keep:YES];
    };
}

- (void)callBackPeripheralsWithKeep:(BOOL)keep{
    NSMutableArray *peripherals = [self getPeripheralList];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: peripherals];
    [pluginResult setKeepCallbackAsBool:keep];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.scanPeripheralsCallBackId];
}

#pragma mark - ***** connect Peripheral *****
- (void)connectPeripheral:(CDVInvokedUrlCommand *)command{
    if (command.arguments.count == 0) {
        [self callBackSuccess:NO callBackId:command.callbackId message:@"请传入需要链接设备的ID"];
        return;
    }
    if (command.arguments.count > 0 && [command.arguments[0] isKindOfClass:[NSString class]]) {
        if (command.arguments[0] == nil || [command.arguments[0] length] == 0) {
            [self callBackSuccess:NO callBackId:command.callbackId message:@"请传入需要链接设备的ID"];
            return;
        }
    }
    
    
    NSString *peripheralId = nil;
    if ([command.arguments[0] isKindOfClass:[NSNumber class]]) {
        NSNumber *pid = command.arguments[0];
        peripheralId = pid.stringValue;
    }else if ([command.arguments[0] isKindOfClass:[NSString class]]){
        peripheralId = command.arguments[0];
    }else{
        [self callBackSuccess:NO callBackId:command.callbackId message:@"传入设备ID的类型错误"];
        return;
    }
    
    if (peripheralId) {
        ELog(@"peripheralId:%@",peripheralId);
        for (CBPeripheral *per in self.peripheralsArray) {
            ELog(@"UUIDString:%@",per.identifier.UUIDString);
            if ([per.identifier.UUIDString isEqualToString:peripheralId]) {
                self.connectPeripheral = per;
            }
        }
    }
    if (self.connectPeripheral == nil) {
        [self callBackSuccess:NO callBackId:command.callbackId message:@"未找到此ID的设备"];
        return;
    }
    [self.manager connectPeripheral:self.connectPeripheral
                     connectOptions:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}
             stopScanAfterConnected:YES
                    servicesOptions:nil
             characteristicsOptions:nil
                      completeBlock:^(HLOptionStage stage, CBPeripheral *peripheral, CBService *service, CBCharacteristic *character, NSError *error) {
                          NSString *statusStr = @"";
                          switch (stage) {
                              case HLOptionStageConnection:{
                                  if (error) {
                                      statusStr = @"连接失败";
                                  } else {
                                      statusStr = @"连接成功";
                                  }
                                  break;
                              }
                              case HLOptionStageSeekServices:{
                                  if (error) {
                                      statusStr = @"查找服务失败";
                                  } else {
                                      statusStr = @"查找服务成功";
                                      [self.servicesArray addObjectsFromArray:peripheral.services];
                                  }
                                  break;
                              }
                              case HLOptionStageSeekCharacteristics:{
                                  // 该block会返回多次，每一个服务返回一次
                                  if (error) {
                                      statusStr = @"查找特性失败";
                                  } else {
                                      statusStr = @"查找特性成功";
                                  }
                                  break;
                              }
                              case HLOptionStageSeekdescriptors:{
                                  // 该block会返回多次，每一个特性返回一次
                                  if (error) {
                                      statusStr = @"查找特性的描述失败";
                                  } else {
                                      statusStr = @"查找特性的描述成功";
                                  }
                                  break;
                              }
                              default:
                                  break;
                          }
                          [self callBackSuccess:NO callBackId:command.callbackId message:statusStr];
                      }];
}

#pragma mark - ***** 获取 设备列表 *****
- (void)getPeripherals:(CDVInvokedUrlCommand *)command{
    NSMutableArray *peripherals = [self getPeripheralList];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: peripherals];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSMutableArray *)getPeripheralList {
    NSMutableArray *peripherals = @[].mutableCopy;
    for (int i = 0; i < self.peripheralsArray.count; i++) {
        NSMutableDictionary *peripheralDic = @{}.mutableCopy;
        CBPeripheral *p = [self.peripheralsArray objectAtIndex:i];
        
        NSString *uuid = p.identifier.UUIDString;
        [peripheralDic setObject:uuid forKey:@"uuid"];
        [peripheralDic setObject:uuid forKey:@"id"];
        NSString *name = [p name];
        if (!name) {
            name = [peripheralDic objectForKey:@"uuid"];
        }
        [peripheralDic setObject:name forKey:@"name"];
        [peripherals addObject:peripheralDic];
    }
    return peripherals;
}


#pragma mark - ***** printer method *****
- (void)appentData:(CDVInvokedUrlCommand *)command{
    [self.commandDelegate runInBackground:^{
        if (command.arguments.count > 0) {
            NSString *jsonStr = command.arguments[0];
            ELog(@"jsonStr : %@", jsonStr);
            [self createDate];
            _printerInfo = nil;

            for (MKPrinterInfoModel *model in self.printerModelArray) {
                switch (model.infoType) {
                    case MKBTPrinterInfoType_text:
                        [self.printerInfo appendText:model.text alignment:[model getAlignment] fontSize:[model getFontSize]];
                        break;
                    case MKBTPrinterInfoType_textList:{
                        [self appentTextListWith:model];
                    }
                        break;
                    case MKBTPrinterInfoType_barCode:
                        [self.printerInfo appendBarCodeWithInfo:model.text alignment:[model getAlignment] maxWidth:model.maxWidth];
                        break;
                    case MKBTPrinterInfoType_qrCode:
                        [self.printerInfo appendQRCodeWithInfo:model.text size:model.qrCodeSize alignment:[model getAlignment]];
                        break;
                    case MKBTPrinterInfoType_image:{
                        UIImage *image = [UIImage mk_imageWithBase64:model.text];
                        [self.printerInfo appendImage:image alignment:[model getAlignment] maxWidth:300];
                    }
                        break;
                    case MKBTPrinterInfoType_seperatorLine:
                        [self.printerInfo appendSeperatorLine];
                        break;
                    case MKBTPrinterInfoType_footer:
                        [self.printerInfo appendFooter:model.text];
                        break;
                    default:
                        break;
                }
            }
            [self.printerInfo appendNewLine];
            [self.printerInfo appendNewLine];
        }

        [self callBackSuccess:YES callBackId:command.callbackId message:[NSString stringWithFormat:@"callBack:%@",command.arguments[0]]];
    }];
}

- (void)appentTextListWith:(MKPrinterInfoModel *)model{
    if (model.textArray.count == 2) {
        if (model.offset > 0) {
            [self.printerInfo appendTitle:model.textArray[0] value:model.textArray[1] valueOffset:model.offset fontSize:[model getFontSize]];
        }else{
            [self.printerInfo appendTitle:model.textArray[0] value:model.textArray[1]];
        }
    }else if (model.textArray.count == 3){
        [self.printerInfo appendLeftText:model.textArray[0] middleText:model.textArray[1] rightText:model.textArray[2] isTitle:model.isTitle == 1];
    }else if (model.textArray.count == 4){
        [self.printerInfo appendTextArray:model.textArray isTitle:model.isTitle];
    }
}


- (void)finalPrinter:(CDVInvokedUrlCommand *)command{
    if (self.servicesArray.count > 0) {
        for (CBService *service in self.servicesArray) {
            for (CBCharacteristic *character in service.characteristics) {
                CBCharacteristicProperties properties = character.properties;
                if (properties & CBCharacteristicPropertyWrite) {
                    self.chatacter = character;
                }
            }
        }
    }
    
    if (self.chatacter) {
        NSData *mainData = [self.printerInfo getFinalData];
        if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
            [self.manager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
                if (!error) {
                    ELog(@"写入成功");
                }
            }];
        } else if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            [self.manager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithoutResponse];
        }
    }
}

#pragma mark - ***** setup printer info *****
- (void)resetPrinterInfo:(CDVInvokedUrlCommand *)command{
    _printerInfo = nil;
}

#pragma mark - ***** call back *****
- (void)callBackSuccess:(BOOL)success callBackId:(NSString *)callBackId message:(NSString *)message{
    [self callBackSuccess:success callBackId:callBackId message:message keep:NO];
}

- (void)callBackSuccess:(BOOL)success callBackId:(NSString *)callBackId message:(NSString *)message keep:(BOOL)keep{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:success?CDVCommandStatus_OK:CDVCommandStatus_ERROR messageAsString:message];
    [pluginResult setKeepCallbackAsBool:keep];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackId];
}

/** 控制台打印 log */
- (void)printLog:(CDVInvokedUrlCommand *)command{
    NSString *log = @"";
    if (command.arguments.count > 0) {
        for (int i = 0; i < command.arguments.count; i++) {
            if ([command.arguments[i] isKindOfClass:[NSString class]]) {
                log = [log stringByAppendingString:command.arguments[i]];
            }
        }
    }
    ELog(@"%@",log);
}

- (void)stopPeripheralConnection:(CDVInvokedUrlCommand *)command{
    [self.manager cancelPeripheralConnection];
    [self callBackSuccess:YES callBackId:command.callbackId message:@"断开连接"];
}


#pragma mark - ***** lazy *****
- (HLBLEManager *)manager{
    if (!_manager) {
        _manager = [HLBLEManager sharedInstance];
    }
    return _manager;
}

- (HLPrinter *)printerInfo{
    if (!_printerInfo) {
        _printerInfo = [[HLPrinter alloc] init];
    }
    return _printerInfo;
}

- (NSMutableArray *)peripheralsArray{
    if (!_peripheralsArray) {
        _peripheralsArray = @[].mutableCopy;
    }
    return _peripheralsArray;
}

- (NSMutableArray *)servicesArray{
    if (!_servicesArray) {
        _servicesArray = @[].mutableCopy;
    }
    return _servicesArray;
}

- (NSMutableArray *)printerModelArray{
    if (!_printerModelArray) {
        _printerModelArray = @[].mutableCopy;
    }
    return _printerModelArray;
}

- (void)createDate{
    [self.printerModelArray removeAllObjects];
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_text;
        model.text = @"text-title";
        model.aligmentType = MKBTPrinterAlignmentType_center;
        model.fontType = MKBTPrinterFontType_middle;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.text = @"测试电商服务中心(销售单)";
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_barCode;
        model.text = @"123456789012";
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_seperatorLine;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"时间", @"2016-04-27 10:01:50"];
        model.offset = 150;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"订单", @"4000020160427100150"];
        model.offset = 150;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"其他", @"无"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_text;
        model.text = @"地址:深圳市南山区学府路东深大店阿里看到解放啦肯德基边上";
        model.aligmentType = MKBTPrinterAlignmentType_left;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_seperatorLine;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"商品",@"数量",@"单价"];
        model.isTitle = 1;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"铅笔",@"5",@"2.0"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"橡皮",@"1",@"1.0"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_seperatorLine;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"商品",@"单价",@"数量",@"总价"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"铅笔刀",@"2.00",@"5",@"10.00"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_seperatorLine;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"总计:", @"20"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_textList;
        model.textArray = @[@"实收:",@"100.00"];
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_seperatorLine;
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_qrCode;
        model.text = @"www.baidu.com";
        model.qrCodeSize = 10;
        [self.printerModelArray addObject:model];
    }
    {
        UIImage *image = [UIImage imageNamed:@"ico180"];
        NSString *imgBase64 = [image mk_imageToBase64];        
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_image;
        model.text = @"data:image/png;base64,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";
        [self.printerModelArray addObject:model];
    }
    {
        MKPrinterInfoModel *model = [[MKPrinterInfoModel alloc] init];
        model.infoType = MKBTPrinterInfoType_footer;
        model.text = @"谢谢光临";
        [self.printerModelArray addObject:model];
    }

}


@end


