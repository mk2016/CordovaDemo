//
//  MKTestPlugin.h
//  CordovaDemo
//
//  Created by xmk on 2017/6/10.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface MKTestPlugin : CDVPlugin

- (void)scanForPeripherals:(CDVInvokedUrlCommand *)command;
- (void)getPeripherals:(CDVInvokedUrlCommand *)command;

- (void)printLog:(CDVInvokedUrlCommand *)command;
@end
