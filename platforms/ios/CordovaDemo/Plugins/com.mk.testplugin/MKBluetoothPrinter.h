//
//  MKBluetoothPrinter.h
//  CordovaDemo
//
//  Created by xmk on 2017/6/20.
//
//

#import <Cordova/CDVPlugin.h>

@interface MKBluetoothPrinter : CDVPlugin

- (void)scanForPeripherals:(CDVInvokedUrlCommand *)command;
- (void)getPeripherals:(CDVInvokedUrlCommand *)command;
- (void)connectPeripheral:(CDVInvokedUrlCommand *)command;
- (void)appentData:(CDVInvokedUrlCommand *)command;
- (void)finalPrinter:(CDVInvokedUrlCommand *)command;
- (void)resetPrinterInfo:(CDVInvokedUrlCommand *)command;
- (void)printLog:(CDVInvokedUrlCommand *)command;

@end
