//
//  MKTestPlugin.m
//  CordovaDemo
//
//  Created by xmk on 2017/6/10.
//
//

#import "MKTestPlugin.h"
#import "HLBLEManager.h"

#define MK_WEAKSELF          __weak typeof(self) weakSelf = self;
#define MK_WEAKIFY(var)      __weak typeof(var) weak_##var = var;

@interface MKTestPlugin ()
@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) HLBLEManager *manager;
@property (nonatomic, copy) NSString *scanPeripheralsCallBackId;

@end

@implementation MKTestPlugin

- (HLBLEManager *)manager{
    if (!_manager) {
        _manager = [HLBLEManager sharedInstance];
    }
    return _manager;
}

- (void)scanForPeripherals:(CDVInvokedUrlCommand *)command{
    BOOL bKeepCallBack = NO;
    if (command.arguments.count > 0) {
        NSNumber *repeat = command.arguments[0];
        bKeepCallBack = repeat.integerValue == 1;
    }
    
    self.scanPeripheralsCallBackId = nil;
    self.scanPeripheralsCallBackId = command.callbackId.copy;
    
    __weak HLBLEManager *weakManager = self.manager;
    __weak MKTestPlugin *weakSelf = self;
    NSString *callBackId = command.callbackId;
    NSLog(@"callBackId : %@", callBackId);
    
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
                    
                    NSLog(@"peripheral.name : %@", peripheral.name);
                    if (peripheral.name.length <= 0) {
                        return ;
                    }
                    BOOL isExist = NO;
                    for (int i = 0; i < weakSelf.deviceArray.count; i++) {
                        CBPeripheral *per = weakSelf.deviceArray[i];
                        if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                            isExist = YES;
                            [weakSelf.deviceArray replaceObjectAtIndex:i withObject:per];
                            break;
                        }
                    }
                    if (!isExist) {
                        [weakSelf.deviceArray addObject:peripheral];
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

- (void)callBackSuccess:(BOOL)success callBackId:(NSString *)callBackId message:(NSString *)message{
    [self callBackSuccess:success callBackId:callBackId message:message keep:NO];
}

- (void)callBackSuccess:(BOOL)success callBackId:(NSString *)callBackId message:(NSString *)message keep:(BOOL)keep{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:success?CDVCommandStatus_OK:CDVCommandStatus_ERROR messageAsString:message];
    [pluginResult setKeepCallbackAsBool:keep];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callBackId];
}

- (void)printLog:(CDVInvokedUrlCommand *)command{
    NSString *log = @"";
    if (command.arguments.count > 0) {
        for (int i = 0; i < command.arguments.count; i++) {
            if ([command.arguments[i] isKindOfClass:[NSString class]]) {
                log = [log stringByAppendingString:command.arguments[i]];
            }
        }
    }
    NSLog(@"%@",log);
}

- (void)getPeripherals:(CDVInvokedUrlCommand *)command{
    NSMutableArray *peripherals = [self getPeripheralList];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray: peripherals];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (NSMutableArray *)getPeripheralList {
    NSMutableArray *peripherals = @[].mutableCopy;
    for (int i = 0; i < self.deviceArray.count; i++) {
        NSMutableDictionary *peripheralDic = @{}.mutableCopy;
        CBPeripheral *p = [self.deviceArray objectAtIndex:i];

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
    
    for (int i = 0; i < 5; i++) {
        NSMutableDictionary *peripheralDic = @{}.mutableCopy;
        [peripheralDic setObject:@"66666" forKey:@"uuid"];
        [peripheralDic setObject:@"7777" forKey:@"id"];
        [peripheralDic setObject:@"name" forKey:@"name"];
        [peripherals addObject:peripheralDic];
    }
    return peripherals;
}


- (NSMutableArray *)deviceArray{
    if (!_deviceArray) {
        _deviceArray = @[].mutableCopy;
    }
    return _deviceArray;
}
@end
