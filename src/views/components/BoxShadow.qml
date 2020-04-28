import QtQuick 2.2

Rectangle {
  property bool reversed: false
  width: parent.width
  height: 2
  gradient: Gradient {
    GradientStop {
      position: reversed ? 1.0 : 0.0
      color: reversed ? Qt.rgba(0,0,0,0.05) : Qt.rgba(0,0,0,0.2)
    }

    GradientStop {
      position: reversed ? 0.0 : 1.0
      color: Qt.rgba(0,0,0,0)
    }
  }
}
