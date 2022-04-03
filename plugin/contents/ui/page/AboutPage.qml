import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.5

import ".."
import "../components"

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents


Flickable {
    Layout.fillWidth: true
    ScrollBar.vertical: ScrollBar { id: scrollbar }
    //ScrollBar.horizontal: ScrollBar { }

    contentWidth: width - (scrollbar.visible ? scrollbar.width : 0)
    contentHeight: contentItem.childrenRect.height
    clip: true
    boundsBehavior: Flickable.OvershootBounds

    OptionGroup {
        id: option_group
        header.visible: false
        anchors.left: parent.left
        anchors.right: parent.right

        OptionItem {
            text: 'Requirements'
            text_color: Theme.textColor
            icon: '../../images/information-outline.svg'

            contentBottom: ColumnLayout {
                Text {
                    Layout.fillWidth: true
                    color: Theme.disabledTextColor
                    text: `
                        <ol>
                        <li><i>Wallpaper Engine</i> installed on Steam</li>
                        <li>Subscribe to some wallpapers on the Workshop</li>
                        <li>Select the <i>steamlibrary</i> folder on the Wallpapers tab of this plugin
                            <ul>
                                <li>The <i>steamlibrary</i> which contains the <i>steamapps</i> folder</li>
                                <li><i>Wallpaper Engine</i> needs to be installed in this <i>steamlibrary</i></li>
                            </ul>
                        </li>
                        </ol>
                    `
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                }
            }
        }
        OptionItem {
            visible: libcheck.wallpaper

            text: 'Fix Crashes'
            text_color: Theme.textColor
            icon: '../../images/information-outline.svg'
            contentBottom: ColumnLayout {
                Text {
                    Layout.fillWidth: true
                    color: Theme.disabledTextColor
                    text: `
                        <ol>
                        <li>Remove <i>WallpaperFilePath</i> line in <b>~/.config/plasma-org.kde.plasma.desktop-appletsrc</b></li>
                        <li>Restart KDE</li>
                        </ol>
                    `
                    wrapMode: Text.Wrap
                    textFormat: Text.RichText
                }
            }
        }
        OptionItem {
            icon: '../../images/github.svg'
            text: 'Github Repo'
            text_color: Theme.textColor
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally(Common.repo_url)
            }
        }
        OptionItem {
            text: 'Lib Checking'
            text_color: Theme.textColor
            icon: '../../images/checkmark.svg'
            contentBottom: ListView {
                implicitHeight: contentItem.childrenRect.height

                model: ListModel {}
                clip: false
                property var modelraw: {
                    const _model = [
                        {
                            ok: libcheck.folderlist,
                            name: "*qt-lab-folderlist"
                        },
                        {
                            ok: libcheck.qtwebsockets,
                            name: "*qtwebsockets (qml)"
                        },
                        {
                            ok: pyext && pyext.ok,
                            name: "*python3-websockets"
                        },
                        {
                            ok: libcheck.qtwebchannel,
                            name: "qtwebchannel (qml) (for web)"
                        },
                        {
                            ok: libcheck.wallpaper,
                            name: "plugin lib (for scene)"
                        }
                    ];
                    return _model;
                }
                onModelrawChanged: {
                    this.model.clear();
                    this.modelraw.forEach((el) => {
                        this.model.append(el);
                    });
                }
                delegate: CheckBox {
                    text: name
                    checked: ok
                    enabled: false
                }
            }
        }
    }
}
