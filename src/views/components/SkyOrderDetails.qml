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
  
  ColumnLayout {

    Layout.fillWidth: true
    Layout.fillHeight: true

    // Project
    Label {
      id: projectLabel
      text: '<b>Project: </b>' + manager.selectedOrderTitle
      renderType: Text.NativeRendering
    }

    Label {
      id: projectIdLabel
      anchors.top: projectLabel.bottom
      anchors.topMargin: 4
      text: '<b>Project id: </b>' + manager.selectedOrderId
      renderType: Text.NativeRendering
    }

    Label {
      id: openAppLinkLabel
      anchors.top: projectIdLabel.bottom
      anchors.topMargin: 4
      text: (manager.selectedOrderId == '') ? '<b>Application: </b>' : '<b>Application: </b><a href="https://deployed.dynamaker.com/applications/' + manager.selectedOrderId + '">' + manager.selectedOrderApplication + '</a>'
      renderType: Text.NativeRendering

      onLinkActivated: Qt.openUrlExternally(link)
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
      }
    }

    // File
    Label {
      id: fileNameLabel
      anchors.top: openAppLinkLabel.bottom
      anchors.topMargin: UM.Theme.getSize("default_margin").width
      text: '<b>File name: </b>' + manager.selectedOrderFileNameWithExtension
      renderType: Text.NativeRendering
    }

    Label {
      id: fileSizeLabel
      anchors.top: fileNameLabel.bottom
      anchors.topMargin: 4
      text: '<b>File size: </b>' + manager.selectedOrderFileSize
      renderType: Text.NativeRendering
    }

    // Customer
    Label {
      id: customerLabel
      anchors.top: fileSizeLabel.bottom
      anchors.topMargin: UM.Theme.getSize("default_margin").width
      text: '<b>Customer: </b>' + manager.selectedOrderCustomer
      renderType: Text.NativeRendering
    }

    Label {
      id: contactPersonLabel
      anchors.top: customerLabel.bottom
      anchors.topMargin: 4
      text: '<b>Contact person: </b>' + manager.selectedOrderContactPerson
      renderType: Text.NativeRendering
    }

    Label {
      id: emailLabel
      anchors.top: contactPersonLabel.bottom
      anchors.topMargin: 4
      text: '<b>Email: </b>' + '<a href="mailto:' + manager.selectedOrderContact + '">'+ manager.selectedOrderContact + '</a>'
      renderType: Text.NativeRendering

      onLinkActivated: Qt.openUrlExternally(link)
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
      }
    }
  }
}
