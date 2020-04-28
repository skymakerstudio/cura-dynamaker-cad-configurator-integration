import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.0 as Cura

import "components"

RowLayout {
  Layout.fillWidth: true
  Layout.fillHeight: true

  SkyOrderList {
    id: orderList
    anchors.left: parent.left
    width: Math.round(parent.width * 0.618)
    height: parent.height
  }

  ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true

    spacing: UM.Theme.getSize("default_margin").width

    anchors {
      left: orderList.right
      right: parent.right
      top: parent.top
      bottom: parent.bottom

      leftMargin: UM.Theme.getSize("default_margin").width
      topMargin: UM.Theme.getSize("default_margin").width
      rightMargin: UM.Theme.getSize("default_margin").width
      bottomMargin: UM.Theme.getSize("default_margin").width
    }

    GroupBox {
      visible: manager.hasOrderSelected
      title: "Selected File"

      Layout.fillHeight: true
      implicitWidth: parent.width

      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        bottom: orderActions.top

        bottomMargin: UM.Theme.getSize("default_margin").width
      }

      ColumnLayout {
        id: selectedOrder
        anchors.fill: parent
        spacing: UM.Theme.getSize("default_margin").width

        SkyOrderPreview {
          id: orderPreview
          anchors {
            top: parent.top
            left: parent.left
            right: parent.right
          }
        }

        SkyOrderDetails {
          anchors {
            bottom: parent.bottom
            bottomMargin: UM.Theme.getSize("default_margin").width

            left: parent.left
            right: parent.right
          }
        }
      }
    }

    SkyOrderActions {
      visible: manager.hasOrderSelected

      id: orderActions
      Layout.fillWidth: true

      anchors {
        bottom: parent.bottom
        left: parent.left
        right: parent.right
      }
    }

    Text {
      visible: (manager.hasOrderSelected == false)
      text: "no order selected"
    }
  }
}
