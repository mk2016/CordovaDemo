//=================================================
//enum
//  信息类型
if (typeof BTPInfoType == "undefined"){
    var BTPInfoType = {};
    BTPInfoType.text            = 0;
    BTPInfoType.textList        = 1;
    BTPInfoType.barCode         = 2;
    BTPInfoType.qrCode          = 3;
    BTPInfoType.image           = 4;
    BTPInfoType.seperatorLine   = 5;
    BTPInfoType.footer          = 6;
}
//  字号大小 default:smalle
if (typeof BTPFontType == "undefined"){
    var BTPFontType = {};
    BTPFontType.smalle  = 0;
    BTPFontType.middle  = 1;
    BTPFontType.big     = 2;
}
//  对齐方式  default:center
if (typeof BTPAlignmentType == "undefined"){
    var BTPAlignmentType = {};
    BTPAlignmentType.left   = 0;
    BTPAlignmentType.center = 1;
    BTPAlignmentType.right  = 2;
}


//=================================================
//PrinterInfoHelper
/* 所有参数
 var infoModel = new Object();
 infoModel.infoType = BTPInfoType.text;
 infoModel.text = text;
 infoModel.textArray = ["铅笔刀","2.00","5","10.00"];
 infoModel.fontType = MKBTPFontType.middle;
 infoModel.aligmentType = MKBTPAlignmentType.center;
 infoModel.maxWidth = 300;
 infoModel.qrCodeSize = 12;
 infoModel.offset = 150;
 infoModel.isTitle = 0;
 */

var _printerInfos = [];

function PrinterInfoHelper(){};

PrinterInfoHelper.prototype.resetInfos = function(){
    _printerInfos = [];
}

PrinterInfoHelper.prototype.appendText = function (text, alignment, fontType) {
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.text;
    infoModel.text = text;
    infoModel.fontType = fontType;
    infoModel.aligmentType = alignment;
    _printerInfos.push(infoModel);
}

/* 列表信息
 * textList     : 信息列表，
 * offset       : 实际值偏移量    optional
 */
PrinterInfoHelper.prototype.appendTextList = function (textList, offset) {
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.textList;
    infoModel.textArray = textList;
    infoModel.offset = offset;
    _printerInfos.push(infoModel);
}

/* 条形码
 * text: 条形码 字符串，
 * maxWidth     : 图片宽    optional   default:300
 * alignment    : 对齐方式  optional   default:center
 */
PrinterInfoHelper.prototype.appendBarCode = function (text, maxWidth, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.barCode;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.maxWidth = maxWidth;
    _printerInfos.push(infoModel);
}

/* 二维码
 * text: 二维码 字符串，
 * size(1-16)   : 图片大小  optional   default:12
 * alignment    : 对齐方式  optional   default:center
 */
PrinterInfoHelper.prototype.appendQrCode = function (text, size, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.qrCode;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.qrCodeSize = size;
    _printerInfos.push(infoModel);
}

/* 图片
 * text: image 转成的 base64 字符串，
 * maxWidth     : 图片宽    optional   default:300
 * alignment    : 对齐方式  optional   default:center
 */
PrinterInfoHelper.prototype.appendImage = function (text, maxWidth, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.image;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.maxWidth = maxWidth;
    _printerInfos.push(infoModel);
}

//分割线  ---------------------------
PrinterInfoHelper.prototype.appendSeperatorLine = function(){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.seperatorLine;
    _printerInfos.push(infoModel);
}


PrinterInfoHelper.prototype.appendFooter = function(text){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.footer;
    infoModel.text = text;
    _printerInfos.push(infoModel);
}

PrinterInfoHelper.prototype.getPrinterInfoJsonString = function(){
    var jsonStr = JSON.stringify(_printerInfos);
    return jsonStr;
}

var printerInfoHelper = new PrinterInfoHelper();

window.printerInfoHelper = printerInfoHelper;
window.BTPInfoType = BTPInfoType;
window.BTPFontType = BTPFontType;
window.BTPAlignmentType = BTPAlignmentType;

