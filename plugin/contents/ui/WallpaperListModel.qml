import QtQuick 2.5
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.2

import Qt.labs.folderlistmodel 2.11

Item {
    id: wpItem
    property var workshopDirs
    property string filterStr
    property bool enabled: true

    signal modelStartSync
    signal modelRefreshed

    readonly property var itemTemplate: ({
        workshopid: "",
        path: "", // need convert to qurl
        loaded: false,
        title: "unknown",
        preview: "unknown",
        type: "unknown"
    })

    readonly property ListModel model: ListModel {}

    property var folderModels: []

    WorkerScript {
        id: folderWorker
        source: "folderWorker.mjs"

        // array
        property var folderMapModel: new Map()
        property var model: []

        onMessage: {
            if(messageObject.reply == "loadFolder") {
                this.folderMapModel.set(messageObject.path, messageObject.data);
                this.model = []
                this.folderMapModel.forEach((value, key) => {
                    this.model.push(...value);
                });
                filterToList(wpItem.model, wpItem.filterStr, this.model);
            } else if(messageObject.reply == "filter") {
                wpItem.modelRefreshed();
            }
        }
        function filterToList(listModel, filterStr, data) {
            const filterValues = Common.filterModel.getValueArray(filterStr);

            const msg = {
                action: "filter", 
                data: data,
                model: listModel,
                filters: Common.filterModel.map((el, index) => {
                    return {
                        type: el.type,
                        key: el.key,
                        value: filterValues[index]
                    };
                })
            };

            this.sendMessage(msg);
            wpItem.modelStartSync();
        }

        Component.onCompleted: {
            wpItem.filterStrChanged.connect(function() {
                if(this.enabled) {
                    folderWorker.filterToList(this.model, this.filterStr, folderWorker.model)
                }
            }.bind(wpItem));
        }
    }
    Component.onCompleted: {
        if(!wpItem.enabled) return;
        this.folderModels.forEach(el => el.destroy());
        this.folderModels = [];
        this.workshopDirs.forEach(el => {
            this.folderModels.push(folderCom.createObject(this, {
                folder: el,
                requirFolder: el
            }));
        });
    }
    Component {
        id: folderCom
        FolderListModel {
            property url requirFolder
            onStatusChanged: {
                if(this.folder != requirFolder) return;
                if (wpItem.enabled && this.status === FolderListModel.Ready) {
                    const proxyModel = []
                    const sendMessage = folderWorker.sendMessage.bind(folderWorker);
                    new Promise((resolve, reject) => {
                        // seems qml's "for" is a function
                        const count = this.count;
                        const get = this.get.bind(this);
                        for(let i=0;i < count;i++) {
                            const v = Object.create(wpItem.itemTemplate);
                            v.workshopid = get(i,"fileName");
                            // use qurl to convert to file://
                            v.path = Qt.resolvedUrl(get(i,"filePath")).toString();
                            proxyModel.push(v);
                        }
                        resolve();
                    }).then((value) => {
                        const msg = {
                            action: "loadFolder", 
                            data: proxyModel,
                            path: this.folder
                        };
                        sendMessage(msg);
                    });
                }
            }
        }
    }
}
