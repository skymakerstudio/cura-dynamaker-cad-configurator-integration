import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.5 as Cura

import "components"

Item {
  anchors.fill: parent
  anchors.topMargin: UM.Theme.getSize("default_margin").width
  anchors.leftMargin: UM.Theme.getSize("default_margin").width

  ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true

    Label {
      text: "About"
      font.bold: true
      renderType: Text.NativeRendering
    }

    Label {
      id: row1
      text: "This plugin is developed by the Swedish mass customization engineers at <a href='https://www.skymaker.se/'>SkyMaker AB</a>"
      onLinkActivated: Qt.openUrlExternally(link)
      renderType: Text.NativeRendering
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
      }
    }

    Label {
      anchors.top: row1.bottom
      text: "to help bridge the gap between online configurators and additive manufacturing. \r\nSince the team always have had a faithful Ultimaker 2 trudging on at the office \r\nbeing exposed to numerous experiments and prototypes, the Cura platform was \r\na natural place to start releasing some of the results from our internal development."
      renderType: Text.NativeRendering
    }

    Label {
      text: "Feedback"
      font.bold: true
      renderType: Text.NativeRendering
    }

    Label {
      text: "Please send feedback and bugs to <a href='mailto:info@skymaker.se'>info@skymaker.se</a>!"
      onLinkActivated: Qt.openUrlExternally(link)
      renderType: Text.NativeRendering
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
      }
    }

  }
}
