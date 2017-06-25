//
//  MKPrinterInfoModel.m
//  CordovaDemo
//
//  Created by xmk on 2017/6/22.
//
//

#import "MKPrinterInfoModel.h"

@implementation MKPrinterInfoModel
- (id)init{
    if (self = [super init]) {
        _infoType = MKBTPrinterInfoType_text;
        _fontType = MKBTPrinterFontType_smalle;
        _aligmentType = MKBTPrinterAlignmentType_center;
    }
    return self;
}

- (HLFontSize)getFontSize{
    if (self.fontType == MKBTPrinterFontType_smalle) {
        return HLFontSizeTitleSmalle;
    }else if (self.fontType == MKBTPrinterFontType_middle){
        return HLFontSizeTitleMiddle;
    }else if (self.fontType == MKBTPrinterFontType_big){
        return HLFontSizeTitleBig;
    }else{
        return HLFontSizeTitleSmalle;
    }
}

- (HLTextAlignment)getAlignment{
    if (_aligmentType == MKBTPrinterAlignmentType_left) {
        return HLTextAlignmentLeft;
    }else if (_aligmentType == MKBTPrinterAlignmentType_center){
        return HLTextAlignmentCenter;
    }else if (_aligmentType == MKBTPrinterAlignmentType_right){
        return HLTextAlignmentRight;
    }else{
        return HLTextAlignmentCenter;
    }
}

- (CGFloat)maxWidth{
    if (_maxWidth <= 0) {
        _maxWidth = 300;
    }
    return _maxWidth;
}

- (CGFloat)qrCodeSize{
    if (_qrCodeSize <= 0) {
        _qrCodeSize = 12;
    }
    return _qrCodeSize;
}

@end
