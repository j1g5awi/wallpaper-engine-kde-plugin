import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.5

import "../utils.mjs" as Utils
import ".."
import "../components"

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
// for kcm gridview
import org.kde.kcm 1.1 as KCM
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kquickcontrolsaddons 2.0

RowLayout {
    Layout.fillWidth: true

    property alias cfg_FilterMode: comboxFilter.currentIndex
    
    Control {
        id: left_content
        Layout.fillWidth: true
        Layout.fillHeight: true
        topPadding: 8
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0

        contentItem: ColumnLayout {
            id: wpselsect
            anchors.left: parent.left
            anchors.right: parent.right

            RowLayout {
                id: infoRow
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Item { Layout.fillWidth: true }
                Label {
                    id: workshopidLabel
                    text: "Shopid: " + cfg_WallpaperWorkShopId
                }
                Label {
                    text: "Type: " + cfg_WallpaperType
                }
                Button {
                    id: wpFolderButton
                    implicitWidth: height
                    IconSvg {
                        anchors.margins: 8
                        anchors.fill: parent
                        color: Theme.textColor
                        source: '../../images/folder-outline.svg'
                    }
                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent
                        subText: cfg_SteamLibraryPath?cfg_SteamLibraryPath:"Select steam library dir"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { wpDialog.open() }
                    }
                }
                ComboBox {
                    id: comboxFilter
                    implicitWidth: height * 1.5
                    popup.width: font.pixelSize * 11
                    popup.height: font.pixelSize * 25
                    popup.x: width - popup.width

                    property var modelValues: Common.filterModel.getValueArray(cfg_FilterStr)
                    model: Common.filterModel

                    indicator: IconSvg {
                        anchors.margins: 8
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        color: Theme.textColor
                        source: '../../images/filter.svg'
                    }
                    delegate: ItemDelegate {
                        id: combox_dg
                        width: comboxFilter.popup.width
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 5
                            CheckBox {
                                visible: model.type !== "_nocheck"
                                checked: comboxFilter.modelValues[index]
                                onToggled: combox_dg.toggle()
                            }
                            Label {
                                Layout.fillWidth: true
                                text: model.text
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: parent.toggle()
                        }
                        function toggle() {
                            if(model.type === "_nocheck") return;
                            const modelValues = comboxFilter.modelValues;
                            modelValues[index] = Number(!modelValues[index]);
                            cfg_FilterStr = Utils.intArrayToStr(modelValues);
                        }
                    }
                    
                }
                ComboBox {
                    id: comboxSort
                    Layout.preferredWidth: contentItem.implicitWidth + height
                    popup.width: font.pixelSize * 18
                    popup.x: width - popup.width


                    model: [
                        {
                            text: "Sort By Workshop Id",
                            short: "Id",
                            value: Common.SortMode.Id
                        },
                        {
                            text: "Sort Alphabetically By Name",
                            short: "Alphabetical",
                            value: Common.SortMode.Name
                        },
                        {
                            text: "Show Newest Modified First",
                            short: "Modified",
                            value: Common.SortMode.Modified
                        }
                    ]
                    contentItem: RowLayout { 
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        spacing: 0
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            IconSvg {
                                anchors.margins: 8
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                color: Theme.textColor
                                source: '../../images/arrow-down.svg'
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            text: comboxSort.model[comboxSort.currentIndex].short
                        }
                        Item { Layout.fillWidth: true ; height: 1 }
                    }
                    ButtonGroup { id: sortGroup }
                    delegate: ItemDelegate {
                        width: comboxSort.popup.width
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 5
                            PlasmaComponents.RadioButton {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: modelData.text
                                autoExclusive: true
                                ButtonGroup.group: sortGroup
                                onClicked:   {
                                    comboxSort.currentIndex = index;
                                    comboxSort.popup.close();
                                    cfg_SortMode = Common.cbCurrentValue(comboxSort)
                                }
                                checked: {
                                    checked = index == cfg_SortMode;
                                }
                            }
                        }
                    }
                    Component.onCompleted: currentIndex = Common.cbIndexOfValue(this, cfg_SortMode)
                }
            }

            Loader {
                id: picViewLoader
                Layout.fillWidth: true
                Layout.fillHeight: true

                asynchronous: false
                sourceComponent: picViewCom
                visible: status == Loader.Ready

                Component.onCompleted: {
                    const refreshIndex = () => {
                        if(this.status == Loader.Ready) {
                            this.item.setCurIndex(wpListModel.model);
                        }
                    }
                    wpListModel.modelStartSync.connect(this.item.backtoBegin);
                    wpListModel.modelRefreshed.connect(refreshIndex.bind(this));
                }
            }
            Component { 
                id: picViewCom
                KCM.GridView {
                    id: picViewGrid
                    anchors.fill: parent

                    readonly property var currentModel: view.model.get(view.currentIndex)

                    view.model: wpListModel.model
                    view.delegate: KCM.GridDelegate {
                        // path is file://, safe to concat with '/'
                        text: title
                        actions: [
                            Kirigami.Action {
                                icon.name: favor?"user-bookmarks-symbolic":"bookmark-add-symbolic"
                                tooltip: favor?"Remove from favorites":"Add to favorites"
                                onTriggered: {
                                    if(favor) {
                                        root.customConf.favor.delete(workshopid);
                                    } else {
                                        root.customConf.favor.add(workshopid);
                                    }
                                    view.model.assignModel(index, { favor: !favor });
                                    root.saveCustomConf();
                                }
                            },
                            Kirigami.Action {
                                icon.name: "folder-remote-symbolic"
                                tooltip: "Open Workshop Link"
                                visible: Boolean(workshopid)
                                onTriggered: Qt.openUrlExternally("https://steamcommunity.com/sharedfiles/filedetails/?id=" + workshopid)
                            },
                            Kirigami.Action {
                                icon.name: "document-open-folder"
                                tooltip: "Open Containing Folder"
                                onTriggered: Qt.openUrlExternally(path) 
                            }
                        ]
                        thumbnail: Rectangle {
                            anchors.fill: parent
                            QIconItem {
                                anchors.centerIn: parent
                                width: root.iconSizes.large
                                height: width
                                icon: "view-preview"
                                visible: !imgPre.visible
                            }
                            Image {
                                id: imgPre
                                anchors.fill: parent
                                source: Common.getWpModelPreviewSource(model);
                                sourceSize.width: parent.width
                                sourceSize.height: parent.height
                                fillMode: Image.PreserveAspectCrop//Image.Stretch
                                cache: false
                                asynchronous: true
                                visible: Boolean(preview)
                            }
                        }
                        onClicked: {
                            cfg_WallpaperFilePath = Common.getWpModelFileSource(model);
                            cfg_WallpaperType = type;
                            cfg_WallpaperWorkShopId = workshopid;
                            view.currentIndex = index;
                        }
                    }

                    Kirigami.Heading {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.largeSpacing
                        // FIXME: this is needed to vertically center it in the grid for some reason
                        anchors.topMargin: picViewGrid.height
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        visible: picViewGrid.view.count === 0
                        level: 2
                        text: { 
                            if(!libcheck.folderlist)
                                return `Please make sure qt-labs-folderlistmodel installed, and open this again`;
                            if(!(libcheck.qtwebsockets && pyext))
                                return `Please make sure qtwebsockets(qml module) installed, and open this again`
                            if(!pyext.ok) {
                                return `Python helper run failed: ${pyext.log}`;
                            }
                            if(!cfg_SteamLibraryPath)
                                return "Select your steam library through the folder selecting button above";
                            if(wpListModel.countNoFilter > 0)
                                return `Found ${wpListModel.countNoFilter} wallpapers, but none of them matched filters`;
                            return `There are no wallpapers in steam library's workshop directory`;
                        }
                        opacity: 0.5
                    }
                    function backtoBegin() {
                        view.positionViewAtBeginning();
                    }

                    function setCurIndex(model) {
                        // model, ListModel
                        new Promise((reoslve, reject) => {
                            for(let i=0;i < model.count;i++) {
                                if(model.get(i).workshopid === cfg_WallpaperWorkShopId) {
                                    view.currentIndex = i;
                                    break;
                                }
                            }
                            if(view.currentIndex == -1 && model.count != 0)
                                view.currentIndex = 0;

                            if(!cfg_WallpaperFilePath || cfg_WallpaperFilePath == "")
                                if(view.currentIndex != -1)
                                    view.currentItem.onClicked();

                            resolve();
                        });
                    }
                }
            }

            FileDialog {
                id: wpDialog
                title: "Select steamlibrary folder"
                selectFolder: true
                selectMultiple : false
                nameFilters: [ "All files (*)" ]
                onAccepted: {
                    const path = Utils.trimCharR(wpDialog.fileUrls[0], '/');
                    cfg_SteamLibraryPath = path;
                    wpListModel.refresh();
                }
            }
        }
    }

    Control {
        id: right_content
        Layout.preferredWidth: parent.width / 3
        Layout.fillHeight: true

        readonly property int image_size: 300
        readonly property int content_margin: 16
        property var wpmodel: { 
            return picViewLoader.item.currentModel
            ? Common.wpitemFromQtObject(picViewLoader.item.currentModel)
            : Common.wpitem_template;
        }

        visible: Layout.preferredWidth > image_size + content_margin*2 + right_content_scrollbar.width

        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0

        background: Rectangle {
            color: Theme.view.backgroundColor
        }

        contentItem: Flickable {
            anchors.fill: parent

            ScrollBar.vertical: ScrollBar { id: right_content_scrollbar }

            contentWidth: width - (right_content_scrollbar.visible ? right_content_scrollbar.width : 0)
            contentHeight: flick_content.implicitHeight

            clip: true
            boundsBehavior: Flickable.OvershootBounds

            ColumnLayout {
                id: flick_content
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: right_content.content_margin
                anchors.rightMargin: anchors.leftMargin
                spacing: 8

                AnimatedImage { 
                    id: animated_image; 
                    Layout.topMargin: right_content.content_margin
                    Layout.preferredWidth: right_content.image_size
                    Layout.preferredHeight: Layout.preferredWidth
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                    source: Common.getWpModelPreviewSource(right_content.wpmodel)
                    fillMode: Image.PreserveAspectFit
                    cache: true
                    asynchronous: true
                }

                Text {
                    Layout.alignment: Qt.AlignTop
                    Layout.minimumWidth: 0
                    Layout.fillWidth: true
                    Layout.minimumHeight: implicitHeight

                    text: right_content.wpmodel.title
                    color: Theme.textColor
                    font.bold: true
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    implicitWidth: contentItem.childrenRect.width
                    implicitHeight: contentItem.childrenRect.height

                    orientation: ListView.Horizontal
                    model: right_content.wpmodel.tags
                    clip: false
                    spacing: 8

                    delegate: Control {
                        leftPadding: 8
                        rightPadding: leftPadding
                        topPadding: 4
                        bottomPadding: topPadding

                        background: Rectangle {
                            color: Theme.activeBackgroundColor
                            radius: 8
                        }
                        contentItem: Text {
                            color: Theme.textColor
                            text: model.key
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    Layout.minimumHeight: implicitHeight

                    text: ''
                    readonly property bool _set_text: {
                        const path = Common.getWpModelProjectPath(right_content.wpmodel);
                        if(path) {
                            pyext.readfile(Common.urlNative(path)).then(value => {
                                const project = Utils.parseJson(value);    
                                this.text = project && project.description ? project.description : '';
                            }).catch(reason => console.error(`read '${path}' error\n`, reason));
                        }
                        return true;
                    }
                    color: Theme.textColor
                    font.bold: false
 
                    wrapMode: Text.Wrap
                    textFormat: Text.PlainText
                    horizontalAlignment: Text.AlignLeft
                }
            }
        }
    }
}
