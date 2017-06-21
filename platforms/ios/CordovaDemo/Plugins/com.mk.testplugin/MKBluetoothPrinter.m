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

@interface MKBluetoothPrinter ()
@property (nonatomic, strong) NSMutableArray *peripheralsArray;
@property (nonatomic, strong) HLBLEManager *manager;
@property (nonatomic, copy) NSString *scanPeripheralsCallBackId;
@property (nonatomic, strong) CBPeripheral *connectPeripheral;
@property (nonatomic, strong) HLPrinter *printerInfo;
@property (nonatomic, strong) CBCharacteristic *chatacter;  /**< 可写入数据的特性 */
@property (nonatomic, strong) NSMutableArray *servicesArray;
@end

@implementation MKBluetoothPrinter

#pragma mark - ***** scan peripherals *****
- (void)scanForPeripherals:(CDVInvokedUrlCommand *)command{
    BOOL bKeepCallBack = NO;
    if (command.arguments.count > 0) {
        NSNumber *repeat = command.arguments[0];
        bKeepCallBack = repeat.integerValue == 1;
    }
    
    self.scanPeripheralsCallBackId = nil;
    self.scanPeripheralsCallBackId = command.callbackId.copy;
    
    __weak HLBLEManager *weakManager = self.manager;
    __weak MKBluetoothPrinter *weakSelf = self;
    NSString *callBackId = command.callbackId;
    ELog(@"callBackId : %@", callBackId);
    
    self.manager.stateUpdateBlock = nil;
    self.manager.stateUpdateBlock = ^(CBCentralManager *central) {
        NSString *info = nil;
        BOOL bSuccess = NO;
        switch (central.state) {
            case CBCentralManagerStatePoweredOn:{
                bSuccess = YES;
                info = @"蓝牙已打开，并且可用";
                [weakManager scanForPeripheralsWithServiceUUIDs:nil options:nil didDiscoverPeripheral:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
                    
                    [weakSelf callBackPeripheralsWithKeep:bKeepCallBack];
                    
                    ELog(@"peripheral.name : %@", peripheral.name);
                    if (peripheral.name.length <= 0) {
                        return ;
                    }
                    BOOL isExist = NO;
                    for (int i = 0; i < weakSelf.peripheralsArray.count; i++) {
                        CBPeripheral *per = weakSelf.peripheralsArray[i];
                        if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                            isExist = YES;
                            [weakSelf.peripheralsArray replaceObjectAtIndex:i withObject:per];
                            break;
                        }
                    }
                    if (!isExist) {
                        [weakSelf.peripheralsArray addObject:peripheral];
                    }
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
        [weakSelf callBackSuccess:bSuccess callBackId:command.callbackId message:info];
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
    if (command.arguments[0] == nil) {
        [self callBackSuccess:NO callBackId:command.callbackId message:@"请传入需要链接设备的ID"];
        return;
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
        for (CBPeripheral *per in self.peripheralsArray) {
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
//    for (int i = 0; i < 5; i++) {
//        NSMutableDictionary *peripheralDic = @{}.mutableCopy;
//        [peripheralDic setObject:@"66666" forKey:@"uuid"];
//        [peripheralDic setObject:@"7777" forKey:@"id"];
//        [peripheralDic setObject:@"name" forKey:@"name"];
//        [peripherals addObject:peripheralDic];
//    }
    return peripherals;
}


#pragma mark - ***** printer method *****
- (void)appentData:(CDVInvokedUrlCommand *)command{
    if (command.arguments.count > 0) {
        if (command.arguments[0] && [command.arguments[0] isKindOfClass:[NSNumber class]]){
            NSNumber *infoType = command.arguments[0];
            switch (infoType.integerValue) {
                case MKBTPrinterInfoType_text:
                    [self appendText:command];
                    break;
                case MKBTPrinterInfoType_rank2:
                    [self appendRank2:command];
                    break;
                case MKBTPrinterInfoType_rank3:
                    [self appendRank3:command];
                    break;
                case MKBTPrinterInfoType_barCode:
                    [self appendBarCode:command];
                    break;
                case MKBTPrinterInfoType_qrCode:
                    [self appendQRCode:command];
                    break;
                case MKBTPrinterInfoType_image:
                    
                    break;
                case MKBTPrinterInfoType_seperatorLine:
                    [self appendSeperatorLine];
                    break;
                case MKBTPrinterInfoType_footer:
                    [self appendFooter:command];
                    
                    break;
                default:
                    break;
            }
        }
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

- (void)appendText:(CDVInvokedUrlCommand *)command{
    NSString *text = nil;
    HLTextAlignment alignment = HLTextAlignmentCenter;
    HLFontSize fontSize = HLFontSizeTitleSmalle;
    if (command.arguments.count > 1) {
        if (command.arguments[1] && [command.arguments[1] isKindOfClass:[NSString class]]) {
            text = command.arguments[1];
        }
    }
    if (command.arguments.count > 2) {
        if ([command.arguments[2] integerValue] == MKBTPrinterAlignmentType_left) {
            alignment = HLTextAlignmentLeft;
        }else if ([command.arguments[2] integerValue] == MKBTPrinterAlignmentType_center){
            alignment = HLTextAlignmentCenter;
        }else if ([command.arguments[2] integerValue] == MKBTPrinterAlignmentType_right){
            alignment = HLTextAlignmentRight;
        }
    }
    if (command.arguments.count > 3) {
        if ([command.arguments[3] integerValue] == MKBTPrinterFontType_smalle) {
            fontSize = HLFontSizeTitleSmalle;
        }else if ([command.arguments[3] integerValue] == MKBTPrinterFontType_middle){
            fontSize = HLFontSizeTitleMiddle;
        }else if ([command.arguments[3] integerValue] == MKBTPrinterFontType_big){
            fontSize = HLFontSizeTitleBig;
        }
    }
    [self.printerInfo appendText:text alignment:alignment fontSize:fontSize];
}

- (void)appendRank2:(CDVInvokedUrlCommand *)command{
    
    NSString *title = nil;
    NSString *value = nil;
    NSInteger offset = 0;
    HLFontSize fontSize = HLFontSizeTitleSmalle;
    if (command.arguments.count > 1) {
        if (command.arguments[1] && [command.arguments[1] isKindOfClass:[NSString class]]) {
            title = command.arguments[1];
        }
        
        if (command.arguments.count > 2) {
            if (command.arguments[2] && [command.arguments[2] isKindOfClass:[NSString class]]) {
                value = command.arguments[2];
            }
            
            if (command.arguments.count > 3) {
                if (command.arguments[3]) {
                    offset = [command.arguments[3] integerValue];
                }
                if (command.arguments.count > 4) {
                    if ([command.arguments[4] integerValue] == MKBTPrinterFontType_smalle) {
                        fontSize = HLFontSizeTitleSmalle;
                    }else if ([command.arguments[4] integerValue] == MKBTPrinterFontType_middle){
                        fontSize = HLFontSizeTitleMiddle;
                    }else if ([command.arguments[4] integerValue] == MKBTPrinterFontType_big){
                        fontSize = HLFontSizeTitleBig;
                    }
                }
                [self.printerInfo appendTitle:title value:value valueOffset:offset fontSize:fontSize];
            }else{
                [self.printerInfo appendTitle:title value:value];
            }
        }
    }
}

- (void)appendRank3:(CDVInvokedUrlCommand *)command{
    NSString *left = nil;
    NSString *middle = nil;
    NSString *right = nil;
    BOOL isTitle = NO;
    if (command.arguments.count > 1) {
        if (command.arguments[1] && [command.arguments[1] isKindOfClass:[NSString class]]) {
            left = command.arguments[1];
        }
    }
    if (command.arguments.count > 2) {
        if (command.arguments[2] && [command.arguments[2] isKindOfClass:[NSString class]]) {
            middle = command.arguments[2];
        }
    }
    if (command.arguments.count > 3) {
        if (command.arguments[3] && [command.arguments[3] isKindOfClass:[NSString class]] ) {
            right = command.arguments[3];
        }
    }
    
    if (command.arguments.count > 4) {
        if (command.arguments[4]) {
            isTitle = [command.arguments[4] integerValue] == 1;
        }
    }
    [self.printerInfo appendLeftText:left middleText:middle rightText:right isTitle:isTitle];
}

- (void)appendBarCode:(CDVInvokedUrlCommand *)command{
    NSString *info = nil;
    HLTextAlignment alignment = HLTextAlignmentCenter;
    CGFloat maxWidth = 300;
    if (command.arguments.count > 1) {
        if (command.arguments[1] && [command.arguments[1] isKindOfClass:[NSString class]]) {
            info = command.arguments[1];
        }
    }
    if (command.arguments.count > 2) {
        if ([command.arguments[2] integerValue] == MKBTPrinterAlignmentType_left) {
            alignment = HLTextAlignmentLeft;
        }else if ([command.arguments[2] integerValue] == MKBTPrinterAlignmentType_center){
            alignment = HLTextAlignmentCenter;
        }else if ([command.arguments[2] integerValue] == MKBTPrinterAlignmentType_right){
            alignment = HLTextAlignmentRight;
        }
    }
    if (command.arguments.count > 3) {
        if (command.arguments[3]) {
            maxWidth = [command.arguments[3] floatValue];
        }
    }
    [self.printerInfo appendBarCodeWithInfo:info alignment:alignment maxWidth:maxWidth];
}



- (void)appendImage:(UIImage *)image alignment:(HLTextAlignment)alignment maxWidth:(CGFloat)maxWidth{
    [self.printerInfo appendImage:image alignment:alignment maxWidth:maxWidth];
}

- (void)appendQRCode:(CDVInvokedUrlCommand *)command{
    NSString *info = nil;
    NSInteger size = 12;
    HLTextAlignment alignment = HLTextAlignmentCenter;
    if (command.arguments.count > 1) {
        if (command.arguments[1] && [command.arguments[1] isKindOfClass:[NSString class]]) {
            info = command.arguments[1];
        }
    }
    if (command.arguments.count > 2) {
        if (command.arguments[2]) {
            size = [command.arguments[2] integerValue];
        }
    }
    if (command.arguments.count > 3) {
        if ([command.arguments[3] integerValue] == MKBTPrinterAlignmentType_left) {
            alignment = HLTextAlignmentLeft;
        }else if ([command.arguments[3] integerValue] == MKBTPrinterAlignmentType_center){
            alignment = HLTextAlignmentCenter;
        }else if ([command.arguments[3] integerValue] == MKBTPrinterAlignmentType_right){
            alignment = HLTextAlignmentRight;
        }
    }
    [self.printerInfo appendQRCodeWithInfo:info size:size alignment:alignment];
}

- (void)appendSeperatorLine{
    [self.printerInfo appendSeperatorLine];
}

- (void)appendFooter:(CDVInvokedUrlCommand *)command{
    NSString *footerInfo = nil;
    if (command.arguments.count > 1) {
        if (command.arguments[1] && [command.arguments[1] isKindOfClass:[NSString class]]) {
            footerInfo = command.arguments[1];
        }
    }
    [self.printerInfo appendFooter:footerInfo];
}

- (void)appendCustomData:(NSData *)data{
    [self.printerInfo appendCustomData:data];
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
@end
