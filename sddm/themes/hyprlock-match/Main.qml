import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "black"

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginSucceeded() {}
        function onLoginFailed() {
            password.text = ""
            password.focus = true
        }
    }

    // Background Image with Blur
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        smooth: true
    }

    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 50
    }

    // Overlay for contrast and brightness adjustment
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.15
    }

    // Main Container
    Item {
        anchors.fill: parent

        // Clock
        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.15
            text: Qt.formatTime(new Date(), "hh:mm")
            color: "rgba(216, 222, 233, 0.70)"
            font.family: "SF Pro Display"
            font.weight: Font.Bold
            font.pixelSize: 130

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatTime(new Date(), "hh:mm")
            }
        }

        // Date
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: clock.bottom
            anchors.topMargin: 20
            text: Qt.formatDate(new Date(), "dddd, dd MMMM")
            color: "rgba(216, 222, 233, 0.70)"
            font.family: "SF Pro Display"
            font.weight: Font.Bold
            font.pixelSize: 30
        }

        // Profile Picture
        Rectangle {
            id: profilePic
            width: 240
            height: 240
            radius: 120
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.45
            color: "transparent"
            clip: true

            Image {
                anchors.fill: parent
                source: "avatar.jpg"
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
        }

        // Username Label
        Text {
            id: usernameLabel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: profilePic.bottom
            anchors.topMargin: 20
            text: "Hi, " + sddm.userName
            color: "rgba(216, 222, 233, 0.70)"
            font.family: "SF Pro Display"
            font.weight: Font.Bold
            font.pixelSize: 25
        }

        // Password Input Field
        Rectangle {
            id: passwordContainer
            width: 250
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: usernameLabel.bottom
            anchors.topMargin: 70
            radius: 5
            color: "rgba(100, 114, 125, 0.4)"
            border.width: 2
            border.color: "transparent"

            TextField {
                id: password
                anchors.fill: parent
                anchors.margins: 10
                placeholderText: "Enter Password"
                placeholderTextColor: "rgba(255, 255, 255, 0.6)"
                echoMode: TextInput.Password
                color: "rgb(200, 200, 200)"
                font.family: "SF Pro Display"
                font.weight: Font.Bold
                font.pixelSize: 16
                background: Rectangle { color: "transparent" }
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                focus: true

                Keys.onReturnPressed: {
                    sddm.login(sddm.userName, password.text, sessionIndex)
                }

                Keys.onEnterPressed: {
                    sddm.login(sddm.userName, password.text, sessionIndex)
                }
            }
        }

        // Session selector (hidden but functional)
        ComboBox {
            id: session
            width: 0
            height: 0
            visible: false
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "name"
        }
    }

    Component.onCompleted: {
        password.forceActiveFocus()
    }

    property int sessionIndex: session.currentIndex
}
