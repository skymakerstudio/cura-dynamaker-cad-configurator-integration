import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.0 as Cura

// the popup window
Window {
  id: orderQueue

  // window configuration
  color: UM.Theme.getColor("main_background")
  width: Math.round(UM.Theme.getSize("modal_window_minimum").width * 1.2)
  height: Math.round(width * 0.618)
  minimumWidth: width
  minimumHeight: height
  maximumWidth: width
  maximumHeight: height

  // translations
  UM.I18nCatalog {
    id: catalog
    name: "DynaMaker - File2Machine"
  }

  title: catalog.i18nc("@title", "DynaMaker - File2Machine")

  MouseArea
  {
    anchors.fill: parent
    focus: true

    onClicked: {
      focus = true
    }

    Keys.onPressed: {
      if (event.key == Qt.Key_Left) {
        loader.source = ""
        manager.reload()
        loader.source = "./Main.qml"
      }
    }
  }

  Loader {
    id: loader
    width: parent.width
    height: parent.height
    source: "Main.qml"
  }
}
