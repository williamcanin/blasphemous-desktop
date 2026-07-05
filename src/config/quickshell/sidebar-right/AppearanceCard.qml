import QtQuick
import QtQuick.Layouts
import Quickshell.Io

BaseCard {
    cardTitle: Strings.cardTitleAppearance
    cardIcon:  "»"

    property bool sysinfoEnabled: true

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 52
            iconText: "\uf03e"
            label: Strings.btnWallpaper
            onClicked: wallpaperProc.running = true
        }

        GlassButton {
            Layout.fillWidth: true
            implicitHeight: 52
            iconText: "\uf53f"
            label: Strings.btnTheme
            onClicked: themeProc.running = true
        }
    }

    Item { Layout.preferredHeight: 4 }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            id: sysinfoToggleBtn
            width: 32; height: 32; radius: 6

            color: {
                if (!sysinfoEnabled) return Theme.bgCardAlt
                if (sysinfoToggleArea.containsMouse) return Theme.accentDim
                return Theme.bgCard
            }
            border.color: sysinfoEnabled ? Theme.accent : Theme.danger
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: sysinfoEnabled ? "\uf0ca" : "\uf00d"
                color: sysinfoEnabled ? Theme.accent : Theme.danger
                font.family: "Font Awesome 6 Free"
                font.pixelSize: 14
                font.weight: Font.Black
            }

            MouseArea {
                id: sysinfoToggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    toggleSysinfoProc.turnOn = !sysinfoEnabled
                    toggleSysinfoProc.running = true
                }
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: Strings.sysinfoTitle
                color: Theme.fgText
                font.pixelSize: 11
                font.family: "monospace"
                font.weight: Font.Medium
            }

            Text {
                text: sysinfoEnabled ? Strings.sysinfoEnabled : Strings.sysinfoDisabled
                color: sysinfoEnabled ? Theme.accent : Theme.danger
                font.pixelSize: 9
                font.family: "monospace"
                opacity: 1
            }
        }

        Text {
            text: sysinfoEnabled ? "ON" : "OFF"
            color: sysinfoEnabled ? Theme.accent : Theme.danger
            font.pixelSize: 8
            font.family: "monospace"
            font.weight: Font.Bold
            font.letterSpacing: 2
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: checkSysinfoProc.running = true
    }

    Process {
        id: wallpaperProc
        command: ["bash", "-c", "sh $HOME/.config/hypr/scripts/wallpaper-pick.sh"]
    }

    Process {
        id: themeProc
        command: ["sh", "-c", "$HOME/.config/my-environment/sh/theme-switch.sh"
        ]
        onExited: Theme.reloadActiveTheme()
    }

    Process {
        id: checkSysinfoProc
        command: ["bash", "-c", "[ -f $HOME/.cache/waybar/sysinfo-state ] && cat $HOME/.cache/waybar/sysinfo-state || echo enabled"]
        stdout: SplitParser {
            onRead: data => {
                sysinfoEnabled = data.trim() === "enabled"
            }
        }
    }

    Process {
        id: toggleSysinfoProc
        property bool turnOn: true
        command: ["bash", "-c", turnOn
            ? "echo enabled > $HOME/.cache/waybar/sysinfo-state; pkill -f 'waybar.*sysinfo' 2>/dev/null; sleep 0.3; waybar -c $HOME/.config/waybar/sysinfo.jsonc -s $HOME/.config/waybar/sysinfo.css &"
            : "echo disabled > $HOME/.cache/waybar/sysinfo-state; pkill -f 'waybar.*sysinfo'"
        ]
        onExited: {
            if (exitCode === 0) {
                sysinfoEnabled = turnOn
            }
        }
    }
}
