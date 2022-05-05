import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.5
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

import "page"

ColumnLayout {
    id: root
    anchors.fill: parent
    anchors.topMargin: 5
    spacing: 5
    
    property string cfg_SteamLibraryPath
    property string cfg_WallpaperWorkShopId
    property string cfg_WallpaperSource
    property string cfg_FilterStr
    property int    cfg_SortMode

    property alias  cfg_Fps:                settingPage.cfg_Fps
    property alias  cfg_Volume:             settingPage.cfg_Volume
    property alias  cfg_VideoRate:          settingPage.cfg_VideoRate
    property alias  cfg_MuteAudio:          settingPage.cfg_MuteAudio
    property alias  cfg_MouseInput:         settingPage.cfg_MouseInput
    property alias  cfg_ResumeTime:         settingPage.cfg_ResumeTime
    property alias  cfg_SwitchTimer:        settingPage.cfg_SwitchTimer
    property alias  cfg_RandomizeWallpaper: settingPage.cfg_RandomizeWallpaper
    property int    cfg_DisplayMode
    property int    cfg_FocusPauseMode
    property int    cfg_MaximizedPauseMode

    //property string cfg_BackgroundColor: "black"
    //property alias  cfg_FilterMode: wallpaperPage.cfg_FilterMode

    property string cfg_CustomConf
    property var customConf: {
        customConf = Common.loadCustomConf(cfg_CustomConf);
    }

    property var iconSizes: {
        if(PlasmaCore.Units) {
            iconSizes = PlasmaCore.Units.iconSizes;
        } else {
            iconSizes = {
                large: 48
            }
        }
    }
    property var themeWidth: {
        if(PlasmaCore.Theme && PlasmaCore.Theme.mSize) {
            themeWidth = PlasmaCore.Theme.mSize(theme.defaultFont).width;
        } else if(theme) {
            themeWidth = theme.mSize(theme.defaultFont).width;
        } else {
            themeWidth = font.pixelSize;
        }
    }

    property var libcheck: ({
        wallpaper: Common.checklib_wallpaper(root),
        qtwebsockets: Common.checklib_websockets(root),
        qtwebchannel: Common.checklib_webchannel(root)
    })

    property var pyext: {
        if(!libcheck.qtwebsockets) {
            pyext = null
        } else {
            pyext = Qt.createQmlObject(`
                import QtQuick 2.0;
                Pyext {}
            `, this);
        }
    }
    WallpaperListModel {
        id: wpListModel
        workshopDirs: Common.getProjectDirs(cfg_SteamLibraryPath)
        filterStr: cfg_FilterStr
        sortMode: cfg_SortMode
        initItemOp: (item) => {
            if(!root.customConf) return;
            item.favor = root.customConf.favor.has(item.workshopid);
        }
        enabled: Boolean(cfg_SteamLibraryPath)
        readfile: pyext.readfile
    }

    Component.onDestruction: {
        if(this.pyext) this.pyext.destroy();
        if(this.wpListModel) this.wpListModel.destroy();
    }

    function saveCustomConf() {
        cfg_CustomConf = Common.prepareCustomConf(this.customConf);
    }


    // Content

    PlasmaComponents.TabBar {
        id: bar
        implicitWidth: font.pixelSize*8 * 3
        PlasmaComponents.TabButton {
            text: 'Wallpapers'
            display: PlasmaComponents.TabButton.TextOnly
        }
        PlasmaComponents.TabButton {
            text: 'Settings'
            display: PlasmaComponents.TabButton.TextOnly
        }
        PlasmaComponents.TabButton {
            text: 'About'
            display: PlasmaComponents.TabButton.TextOnly
        }
    }

    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: bar.currentIndex

        WallpaperPage {
            id: wallpaperPage
        }

        SettingPage {
            id: settingPage
        }

        AboutPage {}
    }
}
