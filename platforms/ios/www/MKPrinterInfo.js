var s_sharePrinterInfo = null;

function MKPrinterInfo () {};
MKPrinterInfo.prototype.getInstance = function () {
    if (!s_sharePrinterInfo) {
        s_sharePrinterInfo = new MKPrinterInfo();
    }
    return s_sharePrinterInfo;
}

initialize: function () {
    // this.printerInfos = new array();
       console.log("initialize");
}

resetInfo: function () {
    // this.printerInfos = [];
    console.log("resetInfo");
 }

appendText: function (text, alignment, fontSize) {
    var infoModel = new Object();
            infoModel.infoType = MKBTPInfoType.text;
            infoModel.text = text;
            infoModel.textArray = ["铅笔刀","2.00","5","10.00"];
            infoModel.fontType = MKBTPFontType.middle;
            infoModel.aligmentType = MKBTPAlignmentType.center;
            infoModel.maxWidth = 300;
            infoModel.qrCodeSize = 12;
            infoModel.offset = 150;
            infoModel.isTitle = 0;
            var jsonStr = JSON.stringify(infoModel)
            console.log(jsonStr)
    console.log("appendText");
}

appendTextList: function (textList, offset, fontSize, isTitle) {
    console.log("appendTextList");
}

appendBarCode: function (text, alignment, maxWidth){
    console.log("appendBarCode");
}

appendQrCode: function (text, alignment, size){
    console.log("appendQrCode");
}

appendSeperatorLine: function(){
    console.log("appendSeperatorLine");
}

appendFooter: function (text){
    console.log("appendFooter");
}

