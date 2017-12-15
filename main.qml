import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2


ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 600
    title: qsTr("Metric k-center solver")

    Connections {
        target: approxFacade
        onDataAvailable: {
            var ctx = drawingCanvas.getContext("2d");

            var c1 = {"x":approxFacade.getX(0), "y":approxFacade.getY(0)};
            var r1 = approxFacade.getR(0);
            addCenter(ctx, c1, "green");

            for(var i = 1; i < k_centers.text; i++){
                console.log("RADIUS is " + approxFacade.getR(i))
                var c = {"x":approxFacade.getX(i), "y":approxFacade.getY(i)};
                var r = approxFacade.getR(i);
                addCenter(ctx, c, "blue");
                if(k_centers.text-1 != i){
                    //addRadius(ctx, c, r);
                }
            }

            drawingCanvas.requestPaint();
            pbar.visible = false;
        }
        onProgressUpdate: progUpdate(val);
        onProgressMaxVal: progMax(val);
    }

    property var cities: [];

    function progUpdate(val){
        pbar.value = val;
        progressTxt.text = val + "/" + pbar.maximumValue
    }

    function progMax(val){
        pbar.maximumValue = val;
    }

    function drawLine(ctx, objFrom, objTo){
        ctx.lineWidth = 1;
        ctx.strokeStyle = "red"
        ctx.beginPath()
        ctx.moveTo(objFrom.x, objFrom.y)
        ctx.lineTo(objTo.x, objTo.y)
        ctx.closePath()
        ctx.stroke()
        drawingCanvas.requestPaint();
    }

    function drawCircle(ctx, obj, color){
        ctx.beginPath();
        ctx.fillStyle = color;
        ctx.moveTo(obj.x, obj.y);
        ctx.arc(obj.x, obj.y, 1, 0, Math.PI * 2, false);
        ctx.lineTo(obj.x, obj.y);
        ctx.fill();
    }

    function writeLabel(ctx, objFrom, objTo, label){
        var lblPos = {"x":0,"y":0};
        lblPos.x = (objFrom.x + objTo.x)/2;
        lblPos.y = (objFrom.y + objTo.y)/2;

        ctx.fillStyle = "black";
        ctx.font = "12px sans-serif";
        ctx.fillText(label, lblPos.x, lblPos.y);
        drawingCanvas.requestPaint();
    }

    function addCenter(ctx, obj, color){
        ctx.beginPath();
        ctx.fillStyle = color;
        ctx.moveTo(obj.x, obj.y);
        ctx.arc(obj.x, obj.y, 1, 0, Math.PI * 2, false);
        ctx.lineTo(obj.x, obj.y);
        ctx.fill();
        drawingCanvas.requestPaint();
    }

    function addRadius(ctx, obj, radius){
        ctx.globalAlpha = 0.4;
        ctx.beginPath();
        ctx.lineWidth = 1;
        ctx.strokeColor = "red"
        ctx.strokeStyle = "red"
        ctx.fillStyle = "#3399ff"
        ctx.moveTo(obj.x, obj.y);
        ctx.arc(obj.x, obj.y, radius, 0, Math.PI * 2, false);
        ctx.lineTo(obj.x, obj.y);
        ctx.fill();

        drawingCanvas.requestPaint();
        ctx.globalAlpha = 1;
    }

    function restoreCanvas(){
        var ctx = drawingCanvas.getContext("2d");
        for(var i=0; i<cities.length; i++){
            drawCircle(ctx, cities[i],"red");
        }

        console.log("key: " + JSON.stringify(centers));

        for(var j in centers){
            console.log("OBJ to draw:" + JSON.stringify(centers[j]));
            drawCircle(ctx, centers[j],"blue");
        }
    }

    function clearCanvas(){
        startBtn.enabled = true
        var width = drawingCanvas.width;
        var height = drawingCanvas.height;
        var ctx = drawingCanvas.getContext("2d");
        ctx.reset();
        cities = []
        approxFacade.init();

        drawingCanvas.requestPaint();
    }

    function generateRandomCities(count){
        var width = drawingCanvas.width;
        var height = drawingCanvas.height;
        var ctx = drawingCanvas.getContext("2d");


        for(var i=0; i<count; i++){
            var obj = {"x":Math.floor((Math.random() * (width-30)))+15, "y":Math.floor((Math.random() * (height-30)))+15}
            approxFacade.setCity(obj.x, obj.y);
            cities.push(obj);
            drawCircle(ctx, obj, "red");
        }

        drawingCanvas.requestPaint();
    }

    Dialog {
        id: dialog
        visible: false
        title: "Choose a date"

        function flash(msg){
            dialogText.text = msg;
            dialog.visible = true;
        }

        standardButtons: StandardButton.Ok

        onAccepted: console.log("Saving the date " +
                                calendar.selectedDate.toLocaleDateString())
        Text {
            id: dialogText
            text: "ciao"
        }

    }

    Dialog {
        id: randomDialog
        visible: false
        title: "Choose random cities count"

        standardButtons: StandardButton.Ok | StandardButton.Cancel

        onAccepted: {
            generateRandomCities(randomDialogTxt.text)
        }

        onRejected: visible = false
        RowLayout {
            Text{
                text: "Random cities count: "
            }
            TextField {
                id: randomDialogTxt
                text: "1"
            }
        }

    }


    Component.onCompleted: {
        approxFacade.init();
    }

    Row {
        id: mainPan
        width: 600
        height: 600
        ProgressBar {
            id: pbar
            visible: false
            value: 50
            width: parent.width
            minimumValue: 0
            maximumValue: k_centers.text - 1

            Text {
                id: progressTxt
                text: "0/0";
                color: "black"
                anchors.centerIn: parent
            }

        }

        Canvas {
            id: drawingCanvas
            width: 600
            height: 600

            onPaint: {

            }
            MouseArea {
                id: canvasid
                anchors.fill: parent
                onClicked: {
                    if(!startBtn.enabled){
                        clearCanvas();

                    }


                    var ctx = drawingCanvas.getContext("2d");

                    var obj = {"x":Math.round(mouseX), "y":Math.round(mouseY)};
                    drawCircle(ctx, obj, "red");
                    drawingCanvas.requestPaint();

                    cities.push(obj);
                    console.log(approxFacade);
                    approxFacade.setCity(Math.round(mouseX), Math.round(mouseY));
                    city_count.text = cities.length
                }
            }
        }


    }

    Rectangle {
        anchors.right: separatorPan.left
        height: 600
        width: 2
        color: "#c9ddfc"
    }

    Rectangle {
        id: separatorPan
        anchors.right: configPan.left
        height: 600
        width: 7
        color: "white"
    }

    Rectangle {
        id: configPan
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 200
        height: 600

        ColumnLayout {
            anchors.topMargin: 50
            anchors.leftMargin: 50

            UnderlinedText {
                title: "Configuration"
            }

            Rectangle {
                id: settingsPan
                height: 100
                color:"blue"
                width: childrenRect.width

                GridLayout {
                    columns: 2
                    anchors.fill: parent

                    Text {
                        text: "Centers:"
                    }
                    TextField {
                        id: k_centers
                        text: "2"
                        Layout.preferredWidth: 40
                    }

                    Text{
                        text: "Algorithm:"
                    }

                    ComboBox {
                        id: algorithm
                        visible: true
                        width: 100
                        model: [ "2Approx", "Bruteforce"]
                    }


                    ToolButton {
                        id: startBtn
                        text: "Resolve"
                        onClicked: {
                            if(cities.length > 0){
                                if(k_centers.text > 0){
                                    startBtn.enabled = false
                                    approxFacade.setCenterCount(k_centers.text);
                                    pbar.visible = true;
                                    //                    startBtn.visible = false;
                                    //                    stepBtn.visible = true;
                                    //                    k_centers.enabled = false;
                                    //                    finishBtn.visible = true;
                                    approxFacade.resolveImmediate(algorithm.currentText);
                                    stopBtn.visible = true;
                                    startBtn.visible = false;
                                }else{
                                    dialog.flash("Impossible run algorithm with 0 centers!");
                                }
                            }else{
                                dialog.flash("City count is not valid");
                            }

                        }
                    }

                    ToolButton {
                        id: stopBtn
                        visible: false
                        text: "STOP"
                        onClicked: {
                            approxFacade.stop();
                            startBtn.visible = true;
                            stopBtn.visible = false;
                            pbar.visible = false;
                        }
                    }

                    //            ToolButton {
                    //                id: stepBtn
                    //                visible: false
                    //                text: ">>>"
                    //                onClicked: {
                    //                    console.log("start clicked")
                    //                    stepOver();


                    //                }
                    //            }

                    ToolButton {
                        id: finishBtn
                        visible: false;
                        text: "Finish"
                        onClicked: {
                            finishAll();
                        }
                    }
                }

            }

            UnderlinedText {
                anchors.top: settingsPan.bottom
                title: "Utilities"
            }

            RowLayout {
                Button {
                    id: clearBtn
                    visible: true;
                    text: "Clear"
                    onClicked: {
                        clearCanvas();
                    }
                }

                Button {
                    id: randomBtn
                    visible: true
                    text: "Random"
                    onClicked: {
                        randomDialog.visible = true
                    }
                }
            }

            Rectangle {
                color: "red"
                height: childrenRect.height
                width: childrenRect.width

                ToolButton {
                    visible: true;
                    text: "Random"
                    onClicked: {

                    }
                }


            }
        }


    }
}
