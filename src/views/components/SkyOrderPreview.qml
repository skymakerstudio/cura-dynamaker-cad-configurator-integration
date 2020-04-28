import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.0 as Cura

Item {
  width: parent.width
  height: childrenRect.height

  Label {
    text: "No preview available"
    visible: manager.selectedOrderPreview == ""

    anchors {
      topMargin: UM.Theme.getSize("default_margin").width
      horizontalCenter: parent.horizontalCenter
    }

    font: UM.Theme.getFont("default")
    renderType: Text.NativeRendering
  }

  Image {
    id: previewImage
    source: manager.selectedOrderPreview
    sourceSize.width: parent.width
    visible: manager.selectedOrderPreview != ""
  }
}
