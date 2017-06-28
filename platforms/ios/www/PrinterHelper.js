var printerInfos = [];

function PrinterHelper(){}

PrinterHelper.prototype.resetInfos = function(){
    printerInfos = [];
}

PrinterHelper.prototype.appendText = function (text, alignment, fontType) {
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.text;
    infoModel.text = text;
    infoModel.fontType = fontType;
    infoModel.aligmentType = alignment;
    var count = self.printerInfos.push(infoModel);
}

PrinterHelper.prototype.appendTextList = function (textList, isTitle, offset) {
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.textList;
    infoModel.textArray = textList;
    infoModel.isTitle = isTitle;
    infoModel.offset = offset;
    var count = self.printerInfos.push(infoModel);
}


PrinterHelper.prototype.appendBarCode = function (text, alignment, maxWidth){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.barCode;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.maxWidth = maxWidth;
    var count = self.printerInfos.push(infoModel);
}


PrinterHelper.prototype.appendQrCode = function (text, size, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.qrCode;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.qrCodeSize = size;
    var count = self.printerInfos.push(infoModel);
}

PrinterHelper.prototype.appendImage = function (text, maxWidth, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.image;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.maxWidth = maxWidth;
    var count = self.printerInfos.push(infoModel);
}

PrinterHelper.prototype.appendSeperatorLine = function(){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.seperatorLine;
    var count = self.printerInfos.push(infoModel);
}


PrinterHelper.prototype.appendFooter = function(text){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.footer;
    infoModel.text = text;
    var count = self.printerInfos.push(infoModel);
}

PrinterHelper.prototype.getPrinterInfoJsonString = function(){
    var jsonStr = JSON.stringify(printerInfos);
    return jsonStr;
}

var printerHelper = new PrinterHelper();
window.printerInfo = printerHelper;

// 所有参数
// var infoModel = new Object();
// infoModel.infoType = BTPInfoType.text;
// infoModel.text = text;
// infoModel.textArray = ["铅笔刀","2.00","5","10.00"];
// infoModel.fontType = MKBTPFontType.middle;
// infoModel.aligmentType = MKBTPAlignmentType.center;
// infoModel.maxWidth = 300;
// infoModel.qrCodeSize = 12;
// infoModel.offset = 150;
// infoModel.isTitle = 0;



















