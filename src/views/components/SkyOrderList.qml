import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import UM 1.3 as UM
import Cura 1.0 as Cura

Item {
  function getTableModel() {
    var data = UM.ActiveTool.properties.getValue("QueuedJobs");
    var list = [];

    var data = {
      application: 'Demo',
      projectId: 1,
      projectTitle: 'project_tilte',
      deliveryDate: '190112',
      customer: {
        id: 'customer_id',
        name: 'Untitled Customer',
        contact: 'contact@customer.com'
      },
      product: {
        volume: 120
      },
      material: 'PLA',
      quality: 'Fine',
      quantity: 32
    }

    list = [{
      application: data.application,
      customer: data.customer.id,
      material: data.material,
      quality: data.quality,
      quantity: data.quantity,
      volume: data.product.volume,
      deliveryDate: data.deliveryDate,
    }]

    for ( var i = 0; i < 20; i++ ) {
      list.push(list[0])
    }

    return list;
  }

  TableView {
    id: orderList
    width: parent.width
    height: parent.height
    // sortIndicatorVisible: true

    selectionMode: 1
    model: manager.orders

    TableViewColumn {
      role: "timestamp"
      title: "Date"
      width: 160
    }

    TableViewColumn {
      role: "customerId"
      title: "Customer"
      width: 100
    }

    TableViewColumn {
      role: "application"
      title: "Application"
      width: 120
    }

    TableViewColumn {
      role: "size"
      title: "File size"
      width: 60
    }

    TableViewColumn {
      role: "material"
      title: "Material"
      width: 60
    }

    TableViewColumn {
      role: "quantity"
      title: "Qty"
      width: 30
    }

    rowDelegate: Rectangle {
      width: parent.width
      height: 30

      color: (styleData.selected || styleData.hasActiveFocus || styleData.pressed || styleData.row == manager.selectedOrderIndex) ? UM.Theme.getColor("primary") : "white"
      //textColor: (styleData.selected || styleData.hasActiveFocus || styleData.pressed || styleData.row == manager.selectedOrderIndex) ? UM.Theme.getColor("primary_text") : "black"
    }

    onClicked: manager.selectOrders([orderList.currentRow])
    onActivated: manager.selectOrders([orderList.currentRow])
    onPressAndHold: manager.selectOrders([orderList.currentRow])
  }
}
