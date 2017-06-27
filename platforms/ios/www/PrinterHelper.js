var printerInfos = [];

function PrinterHelper(){}

PrinterHelper.prototype.resetInfos = function(){
    printerInfos = [];
    console.log("count:" + printerInfos.length);
}

PrinterHelper.prototype.appendText = function (text, alignment, fontType) {
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.text;
    infoModel.text = text;
    infoModel.fontType = fontType;
    infoModel.aligmentType = alignment;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel);
    console.log("appendText:" + jsonStr);
    console.log("count:" + count);
}

PrinterHelper.prototype.appendTextList = function (textList, isTitle, offset) {
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.textList;
    infoModel.textArray = textList;
    infoModel.isTitle = isTitle;
    infoModel.offset = offset;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel);
    console.log("appendTextList:" + jsonStr);
    console.log("count:" + count);
}


PrinterHelper.prototype.appendBarCode = function (text, alignment, maxWidth){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.barCode;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.maxWidth = maxWidth;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel)
    console.log("appendBarCode:" + jsonStr);
    console.log("count:" + count);
}


PrinterHelper.prototype.appendQrCode = function (text, size, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.qrCode;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.qrCodeSize = size;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel)
    console.log("appendBarCode:" + jsonStr);
    console.log("count:" + count);
}

PrinterHelper.prototype.appendImage = function (text, maxWidth, alignment){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.image;
    infoModel.text = text;
    infoModel.aligmentType = alignment;
    infoModel.maxWidth = maxWidth;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel)
    console.log("appendImage:" + jsonStr);
    console.log("count:" + count);
}

PrinterHelper.prototype.appendSeperatorLine = function(){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.seperatorLine;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel)
    console.log("appendSeperatorLine:" + jsonStr);
    console.log("count:" + count);
}


PrinterHelper.prototype.appendFooter = function(text){
    var infoModel = new Object();
    infoModel.infoType = BTPInfoType.footer;
    infoModel.text = text;
    var count = self.printerInfos.push(infoModel);

    var jsonStr = JSON.stringify(infoModel)
    console.log("appendFooter:" + jsonStr);
    console.log("count:" + count);
}

PrinterHelper.prototype.getPrinterInfoJsonString = function(){
    var jsonStr = JSON.stringify(printerInfos);
    console.log("length:" + printerInfos.length);
    console.log("jsonString:" + jsonStr);
    return jsonStr;
}

var printerHelper = new PrinterHelper();
window.printerInfo = printerHelper;

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
   // var jsonStr = JSON.stringify(infoModel)
   // console.log(jsonStr)
   // console.log("appendText");


















