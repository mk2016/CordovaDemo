//
//  MKConst.h
//  CordovaDemo
//
//  Created by xmk on 2017/6/20.
//
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define DLog(...) NSLog(@"%s, %d, %@", __func__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#   define ELog(fmt, ...) NSLog((@"[Elog] " fmt), ##__VA_ARGS__);
#   define DebugStatus YES
#else
#   define DLog(...)
#   define ELog(...)
#   define DebugStatus NO
#endif

typedef NS_ENUM(NSInteger, MKBTPrinterInfoType) {
    MKBTPrinterInfoType_text            = 0,
    MKBTPrinterInfoType_rank2           = 1,
    MKBTPrinterInfoType_rank3           = 2,
    MKBTPrinterInfoType_barCode         = 3,
    MKBTPrinterInfoType_qrCode          = 4,
    MKBTPrinterInfoType_image           = 5,
    MKBTPrinterInfoType_seperatorLine   = 6,
    MKBTPrinterInfoType_footer          = 7,
};

typedef NS_ENUM(NSInteger, MKBTPrinterFontType) {
    MKBTPrinterFontType_smalle  = 0,
    MKBTPrinterFontType_middle  = 1,
    MKBTPrinterFontType_big     = 2,
};

typedef NS_ENUM(NSInteger, MKBTPrinterAlignmentType) {
    MKBTPrinterAlignmentType_left   = 0,
    MKBTPrinterAlignmentType_center = 1,
    MKBTPrinterAlignmentType_right  = 2,
};