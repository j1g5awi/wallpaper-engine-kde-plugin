import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.5

import ".."
import "../components"

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Flickable {
    id: settingTab
    property alias cfg_Fps: sliderFps.value
    property alias cfg_Volume: sliderVol.value
    property alias cfg_MuteAudio: ckbox_muteAudio.checked
    property alias cfg_MouseInput: ckbox_mouseInput.checked
    property alias cfg_ResumeTime: resumeSpin.value
    property alias cfg_SwitchTimer: randomSpin.value
    property alias cfg_RandomizeWallpaper: ckbox_randomizeWallpaper.checked

    property int comboBoxWidth: themeWidth * 24

    Layout.fillWidth: true
    ScrollBar.vertical: ScrollBar { id: scrollbar }

    contentWidth: width - (scrollbar.visible ? scrollbar.width : 0)
    contentHeight: contentItem.childrenRect.height
    clip: true
    boundsBehavior: Flickable.OvershootBounds

    OptionGroup {
        header.visible: false
        anchors.left: parent.left
        anchors.right: parent.right


        OptionGroup {
            Layout.fillWidth: true
            header.text: 'Common Option'
            header.text_color: Theme.textColor
            header.icon: '../../images/cheveron-down.svg'
            header.color: Theme.activeBackgroundColor

            OptionItem {
                text: 'Focus Window Exists'
                text_color: Theme.textColor
                icon: '../../images/pause.svg'
                actor:  ComboBox {
                    implicitWidth: comboBoxWidth
                    id: focusPauseMode
                    model: [
                        {
                            text: "Keep Running",
                            value: Common.PauseMode.KeepRunning
                        },
                        {
                            text: "Mute Audio",
                            value: Common.PauseMode.MuteAudio
                        },
                        {
                            text: "Pause",
                            value: Common.PauseMode.Pause
                        }
                    ]
                    textRole: "text"
                    onActivated: cfg_FocusPauseMode = Common.cbCurrentValue(this)
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_FocusPauseMode)
                }
            }
            OptionItem {
                text: 'Maximized Window Exists'
                text_color: Theme.textColor
                icon: '../../images/pause.svg'
                actor:  ComboBox {
                    implicitWidth: comboBoxWidth
                    id: maximizedPauseMode
                    model: [
                        {
                            text: "Keep Running",
                            value: Common.PauseMode.KeepRunning
                        },
                        {
                            text: "Mute Audio",
                            value: Common.PauseMode.MuteAudio
                        },
                        {
                            text: "Pause",
                            value: Common.PauseMode.Pause
                        }
                    ]
                    textRole: "text"
                    onActivated: cfg_MaximizedPauseMode = Common.cbCurrentValue(this)
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_MaximizedPauseMode)
                }
            }
            OptionItem {
                text: 'Display'
                text_color: Theme.textColor
                icon: '../../images/window.svg'
                actor: ComboBox {
                    id: displayMode
                    implicitWidth: comboBoxWidth
                    model: [
                        {
                            text: "Keep Aspect Ratio",
                            value: Common.DisplayMode.Aspect
                        },
                        {
                            text: "Scale and Crop",
                            value: Common.DisplayMode.Crop
                        },
                        {
                            text: "Scale to Fill",
                            value: Common.DisplayMode.Scale
                        },
                    ]
                    textRole: "text"
                    onActivated: cfg_DisplayMode = Common.cbCurrentValue(this)
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_DisplayMode)
                }
            }
            OptionItem {
                text: 'Resume Time'
                text_color: Theme.textColor
                icon: '../../images/timer.svg'
                actor: RowLayout {
                    spacing: 0
                    RowLayout {
                        SpinBox {
                            id: resumeSpin
                            width: font.pixelSize * 4
                            height: heightpicker.height
                            from: 1
                            to: 60*1000
                            stepSize: 50
                        }
                        Label { text: " ms" }
                    }
                }
            }
            OptionItem {
                text: 'Randomize Timer'
                text_color: Theme.textColor
                icon: '../../images/time.svg'
                actor: Switch {
                    id: ckbox_randomizeWallpaper
                }
                contentBottom: ColumnLayout {
                    Text {
                        color: Theme.disabledTextColor
                        text: "Randomize wallpapers filtered in the 'Wallpapers' page"
                    }
                    RowLayout {
                        visible: ckbox_randomizeWallpaper.checked
                        Label { 
                            id:heightpicker
                            text: "Randomize every " 
                        }
                        SpinBox {
                            id: randomSpin
                            width: font.pixelSize * 4
                            from: 1
                            to: 60*24*30
                            stepSize: 1
                        }
                        Label { text: " min" }
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            OptionItem {
                text: "Mute Audio"
                text_color: Theme.textColor
                icon: ckbox_muteAudio.checked
                    ? '../../images/volume-off.svg'
                    : '../../images/volume-up.svg'
                actor: Switch {
                    id: ckbox_muteAudio
                }
            }
            OptionItem {
                text: "Volume"
                text_color: Theme.textColor
                visible: !cfg_MuteAudio
                actor: RowLayout {
                    Layout.preferredWidth: displayMode.width
                    Label {
                        Layout.preferredWidth: font.pixelSize * 2
                        text: sliderVol.value.toString()
                    }
                    Slider {
                        id: sliderVol
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        stepSize: 5.0
                        snapMode: Slider.SnapOnRelease
                    }
                }
            }
 
            OptionItem {
                visible: libcheck.wallpaper
                text_color: Theme.textColor
                text: "Mouse Input"
                icon: '../../images/mouse.svg'
                actor: Switch {
                    id: ckbox_mouseInput
                }
            }
       }

        OptionGroup {
            Layout.fillWidth: true

            header.text: 'Scene Option'
            header.text_color: Theme.textColor
            header.icon: '../../images/cheveron-down.svg'
            header.color: Theme.activeBackgroundColor
            visible: libcheck.wallpaper

            OptionItem {
                text: 'Fps'
                text_color: Theme.textColor
                icon: '../../images/tuning.svg'
                actor: RowLayout {
                    Layout.preferredWidth: displayMode.width
                    Label {
                        Layout.preferredWidth: font.pixelSize * 2
                        text: sliderFps.value.toString()
                    }
                    Slider {
                        id: sliderFps
                        Layout.fillWidth: true
                        from: 5
                        to: 60
                        stepSize: 1.0
                        snapMode: Slider.SnapOnRelease
                    }
                }
            }
        }
    }


}

