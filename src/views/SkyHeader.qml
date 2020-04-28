import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import UM 1.4 as UM

import "components"

Item {
  id: header
  width: parent.width
  Layout.fillWidth: true

  height: UM.Theme.getSize("toolbox_header").height

  Row {
    id: bar
    spacing: UM.Theme.getSize("default_margin").width
    height: childrenRect.height
    width: childrenRect.width
    anchors {
      left: parent.left
      leftMargin: UM.Theme.getSize("default_margin").width
    }

    Image {
      sourceSize.height: UM.Theme.getSize("toolbox_header").height
      source: "../assets/skymaker_logo.svg"
    }

    TabButton {
      text: catalog.i18nc("@title:tab", "Orders")
      active: (manager.activeTab == "orders")
      onClicked: manager.setActiveTab("orders")
    }

    TabButton {
      text: catalog.i18nc("@title:tab", "Configure")
      active: (manager.activeTab == "configure")
      onClicked: manager.setActiveTab("configure")
    }

    TabButton {
      text: catalog.i18nc("@title:tab", "About")
      active: (manager.activeTab == "about")
      onClicked: manager.setActiveTab("about")
    }
  }

  Button
  {
    id: syncButton
    anchors {
      verticalCenter: parent.verticalCenter
      right: parent.right
      rightMargin: UM.Theme.getSize("default_margin").width
    }

    text: "Last updated: " + manager.lastSynced

    height: Math.round(0.5 * UM.Theme.getSize("main_window_header").height)
    onClicked: manager.updateOrderList()
    visible: f2m.hasValidApiKey

    hoverEnabled: true

    background: Rectangle
    {
      radius: UM.Theme.getSize("action_button_radius").width
      color: parent.hovered ? UM.Theme.getColor("main_window_header_background") : UM.Theme.getColor("primary_text")
      border.width: UM.Theme.getSize("default_lining").width
      border.color: UM.Theme.getColor("main_window_header_background")
    }

    contentItem: Label
    {
      id: label
      text: "Last updated: " + manager.lastSynced
      font: UM.Theme.getFont("default")
      color: parent.hovered ? UM.Theme.getColor("primary_text") : UM.Theme.getColor("main_window_header_background")
      width: contentWidth
      verticalAlignment: Text.AlignVCenter
      renderType: Text.NativeRendering
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.NoButton
      cursorShape: parent.hovered ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
  }

  BoxShadow {
    anchors.top: bar.bottom
  }
}
