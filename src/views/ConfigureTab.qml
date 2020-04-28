import QtQuick 2.10
//import QtQuick.Controls 2.0
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

    Image {
      id: file2MachineLogo
      //anchors.verticalCenter: parent.verticalCenter
      sourceSize.height: UM.Theme.getSize("toolbox_header").height * 0.75
      source: "../assets/file2machine_logo.png"
    }

    Label {
      anchors.topMargin: UM.Theme.getSize("default_margin").height
      anchors.left: parent.left
      text: "<b>API Key:</b>"
      font: UM.Theme.getFont("default")
      color: UM.Theme.getColor("text")
      renderType: Text.NativeRendering
    }

    RowLayout {
      Layout.fillWidth: true

      TextField {
        id: apiKeyInputField
        Layout.preferredWidth: 600
        readOnly: f2m.hasValidApiKey

        text: f2m.apiKey

        height: updateApiKeyButton.height
        anchors.verticalCenter: updateApiKeyButton.verticalCenter
        anchors.left: parent.left

        placeholderText: "API Key"
      }

      Cura.SecondaryButton {
        //color: "#d31016"
        text: "remove"
        id: removeApiKeyButton
        visible: f2m.hasValidApiKey

        anchors {
          left: apiKeyInputField.right
          leftMargin: UM.Theme.getSize("default_margin").width
        }

        onClicked: {
          f2m.forgetApiKey()
        }
      }

      Cura.SecondaryButton {
        text: "cancel"
        id: cancelApiKeyButton
        visible: (apiKeyInputField.text != f2m.apiKey)

        anchors {
          left: apiKeyInputField.right
          leftMargin: UM.Theme.getSize("default_margin").width
        }

        onClicked: {
          apiKeyInputField.text = f2m.apiKey
          ftm.setApiKey(f2m.apiKey)
        }
      }

      Cura.PrimaryButton {
        text: "update"
        id: updateApiKeyButton
        visible: (apiKeyInputField.text.length > 0) && (apiKeyInputField.text != f2m.tempApiKey)

        anchors {
          left: cancelApiKeyButton.right
          leftMargin: UM.Theme.getSize("default_margin").width
        }

        onClicked: f2m.setApiKey(apiKeyInputField.text)
      }
    }

    Label {
      visible: f2m.tempApiKey !== f2m.apiKey
      text: "Provided API key is invalid"
      font: UM.Theme.getFont("default")
      renderType: Text.NativeRendering
      color: "#d31016"
    }

    Label {
      visible: !f2m.hasValidApiKey
      anchors.topMargin: UM.Theme.getSize("default_margin").height
      anchors.left: parent.left
      text: "No API Key yet? Head over to <a href='https://dynamaker.com/'>dynamaker.com</a> and create your first configurator, and request your file2machine key from support!"
      onLinkActivated: Qt.openUrlExternally(link)
      font: UM.Theme.getFont("default")
      color: UM.Theme.getColor("text")
      renderType: Text.NativeRendering

      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
      }
    }
  }
}
