//
//  MKBluetoothPrinter.h
//  CordovaDemo
//
//  Created by xmk on 2017/6/20.
//
//

#import <Cordova/CDVPlugin.h>

@interface MKBluetoothPrinter : CDVPlugin

/** 扫描 外设 */
- (void)scanForPeripherals:(CDVInvokedUrlCommand *)command;
/** 获取 外设列表 */
- (void)getPeripherals:(CDVInvokedUrlCommand *)command;
/** 连接 外设 */
- (void)connectPeripheral:(CDVInvokedUrlCommand *)command;
/** 拼接数据 */
- (void)appentData:(CDVInvokedUrlCommand *)command;
/** 确认打印 */
- (void)finalPrinter:(CDVInvokedUrlCommand *)command;
/** 重置打印数据 */
- (void)resetPrinterInfo:(CDVInvokedUrlCommand *)command;
/** 打印log */
- (void)printLog:(CDVInvokedUrlCommand *)command;
/** 断开外设连接 */
- (void)stopPeripheralConnection:(CDVInvokedUrlCommand *)command;
@end
