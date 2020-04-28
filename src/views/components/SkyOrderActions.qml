import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.0 as Cura

RowLayout {
  Layout.fillWidth: true
  height: childrenRect.height

  spacing: UM.Theme.getSize("default_margin").width

  Text {
    text: manager.orderHint
    visible: manager.showOrderHint
  }

  Cura.PrimaryButton {
    id: importButton
    text: "Add to build plate"
    anchors {
      right: parent.right
    }
    Layout.rightMargin: UM.Theme.getSize("default_margin").width
    onClicked: manager.importSelectedOrder()

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      cursorShape: parent.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
  }
}
