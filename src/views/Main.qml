import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.0 as Cura

ColumnLayout {
  Layout.fillWidth: true
  Layout.fillHeight: true

  SkyHeader {
    id: header
    anchors.top: parent.top
  }

  Item {
    anchors {
      top: header.bottom
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }

    OrdersTab {
      visible: (manager.activeTab == "orders")
      anchors.fill: parent
    }

    ConfigureTab {
      visible: (manager.activeTab == "configure")
      anchors.fill: parent
    }

    AboutTab {
      visible: (manager.activeTab == "about")
      anchors.fill: parent
    }
  }
}
