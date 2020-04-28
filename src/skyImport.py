import datetime, json, os, tempfile, threading, time, shutil

from cura.CuraApplication import CuraApplication
from PyQt5 import QtWidgets, QtGui
from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot, QUrl, QCoreApplication
from UM.Extension import Extension
from UM.Logger import Logger
from UM.Message import Message
from UM.PluginRegistry import PluginRegistry

from .file2Machine import File2Machine

from .errorCodes import errorCodes

class SkyImport (QObject, Extension):
  def __init__ (self):
    super().__init__()
    self._pluginPath = None # will be set on first open
    self._cura = CuraApplication.getInstance()
    self._cura.fileLoaded.connect(self._onFileImported)

    self._preferences = self._cura.getPreferences()

    self._file2Machine = File2Machine(self._preferences)
    self._file2Machine.apiKeyUpdated.connect(self._onApiKeyChanged)

    self.setMenuName("DynaMaker")
    self.addMenuItem("File2Machine", self._openModal)

    # View State
    self._active_view = None
    self._active_tab = "orders"

    # Orders
    self._orders = []
    self._has_order_selected = False
    self._selected_order = None
    self._selected_order_index = None

    # Sync State
    self._last_synced = "never"
    self._syncTimer = None
    self._sync_time = 10 # seconds
    self._sync() # start sync cycle

    # File Import
    self._temp_folder_path = os.path.join(tempfile.gettempdir(), 'cura-plugin-dynamaker-f2m-temp')
    self._has_pending_import = False
    self._order_hint = ""

    # Clean up any temp files left from previous sessions
    if os.path.exists(self._temp_folder_path):
      try:
        shutil.rmtree(self._temp_folder_path)
      except:
        self._logError("104")


    os.mkdir(self._temp_folder_path)

  """ PyQt Signal Listeners """
  synced = pyqtSignal()
  onTabChanged = pyqtSignal()
  orderSelectionChanged = pyqtSignal()
  orderListStateChanged = pyqtSignal()
  updateOrderHint = pyqtSignal()

  """ PyQt View Handling """
  def _openModal (self):
    if self._active_view is not None:
      self._active_view.destroy()
    
    self._active_view = self._createView()
    
    if (self._active_view is not None):
      self.updateOrderList()
      self._active_view.show()

  def _createView(self):
    # Create the plugin dialog component
    self._pluginPath = PluginRegistry.getInstance().getPluginPath(self.getPluginId())
    path = os.path.join(self._pluginPath, "src", "views", "SkyImport.qml")
    
    view = self._cura.createQmlComponent(path, {
      "manager": self,
      "f2m": self._file2Machine
    })

    if view is None:
      return self._logError("001")
    else:
      Logger.log("d", "File2Machine view created.")
    
    return view

  """ DEBUG """
  @pyqtSlot()
  def reload(self):
    Logger.log("w", "f2m reload window")
    # TODO clear component cache to enable hot reload
    #self._active_view.rootContext().engine().clearComponentCache()

  def _logError(self, code: str):
    Logger.log("e", "f2m error {}: {}".format(code, errorCodes[code]))

  """ TAB HANDLING """
  @pyqtSlot(str)
  def setActiveTab(self, tabName: str):
    self._active_tab = tabName
    self.onTabChanged.emit()

  @pyqtProperty(str, notify = onTabChanged)
  def activeTab(self):
    return self._active_tab

  """ ORDER HANDLING """
  def _sync(self):
    self._syncTimer = threading.Timer(self._sync_time, self._sync)
    self._syncTimer.start()
    self.updateOrderList()

  def _onApiKeyChanged(self):
    self._clearState()
    self.updateOrderList()

  def _getDemoOrders (self):
    if (self._pluginPath is not None):
      with open(os.path.join(self._pluginPath, 'data', 'demo_publications.json'), 'r') as file:
        demoPublications = json.loads(file.read())
        return self._file2Machine.getOrdersFromPublications(demoPublications)

    return []

  def _isInDemoMode (self):
    return (self._file2Machine.hasValidApiKey == False)

  @pyqtSlot()
  def updateOrderList(self):
    if (self._file2Machine.hasValidApiKey):
      self._orders = self._file2Machine.getAllFileOrders() or []
      self._last_synced = datetime.datetime.fromtimestamp(time.time()).strftime('%H:%M:%S')
      self.synced.emit()
    else:
      self._orders = self._getDemoOrders() or []

    self._orders = sorted(self._orders, key = lambda x: x['timestamp'], reverse = True) 

    self.orderListStateChanged.emit()

  @pyqtProperty(list, notify = orderListStateChanged)
  def orders(self):
    return self._orders

  def _getOrderWithIndex(self, index):
    orders = self._orders
    return orders[index] if index <= len(orders) else None

  def _clearState (self):
    self._orders = []
    self._has_order_selected = False
    self._selected_order = None
    self._selected_order_index = None
    self.orderSelectionChanged.emit()

  """ ORDER SELECTION """
  @pyqtSlot(list)
  def selectOrders(self, orderIndexes: list):
    self._selected_order_index = orderIndexes[0]
    selected_orders = [self._getOrderWithIndex(i) for i in orderIndexes]
    # TODO: handle multi-select
    self._selected_order = selected_orders[0]
    self._has_order_selected = True
    self.orderSelectionChanged.emit()
    self.orderListStateChanged.emit()

  @pyqtProperty(int, notify = orderSelectionChanged)
  def selectedOrderIndex(self):
    if (self._selected_order_index is None): return -1
    return self._selected_order_index

  @pyqtProperty(bool, notify = orderSelectionChanged)
  def hasOrderSelected(self):
    return self._has_order_selected

  @pyqtProperty(object, notify = orderSelectionChanged)
  def selectedOrder(self):
    return self._selected_order

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderPreview(self):
    if (self._selected_order is None): return ''
    imgUrl = self._selected_order.get('preview', '')
    if (imgUrl != ''):
      return imgUrl

    if (self._isInDemoMode()):
      fileId = self._selected_order.get('fileId')
      if (fileId == 'demo1'):
        return 'file:///' + os.path.join(self._pluginPath, 'data', 'demo1.png')
      
      if (fileId == 'demo2'):
        return 'file:///' + os.path.join(self._pluginPath, 'data', 'demo2.png')
    

    return ''

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderApplication(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('application', '')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderTitle(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('projectTitle', '')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderId(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('projectId', '')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderCustomer(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('customerId', '')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderContactPerson(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('contact', '')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderContact(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('email', '')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderFileSize(self):
    if (self._selected_order is None): return ''
    return self._selected_order.get('size')

  @pyqtProperty(str, notify = orderSelectionChanged)
  def selectedOrderFileNameWithExtension(self):
    if (self._selected_order is None): return ''
    _name = self._selected_order.get('name')
    if (_name is None): return ''
    _type = self._selected_order.get('type')
    if (_type is None): return ''
    return "{}.{}".format(_name, _type)

  @pyqtProperty(str, notify = synced)
  def lastSynced(self):
    return self._last_synced

  """ ORDER IMPORT """
  @pyqtSlot()
  def importSelectedOrder(self):
    if (self._selected_order is not None):
      fileId = self._selected_order["fileId"]
      
      # Load Demo Model if applicable
      if (self._isInDemoMode()):
        if (fileId == 'demo1'): return self._openFileWithCura(os.path.join(self._pluginPath, 'data', 'demo1.stl'))
        if (fileId == 'demo2'): return self._openFileWithCura(os.path.join(self._pluginPath, 'data', 'demo2.stl'))

      # Load Model from Server
      modelData = self._file2Machine.getFile(fileId)

      if (modelData is None):
        self._showOrderHint("Failed. e:103", time = 3)
        self._logError("103")

      try:
        with tempfile.TemporaryFile(mode="w", delete = False, dir=self._temp_folder_path, suffix=".stl") as temp:
          # file is removed in callback _onFileImported
          temp.write(modelData)
          temp.close()
        
        self._openFileWithCura(temp.name)

      except Exception:
        self._showOrderHint("Failed. e:101", time = 3)
        self._logError("101")

  def _openFileWithCura(self, url):
    self._has_pending_import = True
    self._showOrderHint("Loading...")
    self._cura._openFile(url)

  def _onFileImported(self, file):
    if (self._has_pending_import):
      if (file is None):
        self._showOrderHint("Failed. e:102", time = 3)
        self._logError("102")
      else:
        self._showOrderHint("Added!", time = 1)
      
      self._has_pending_import = False
      
      if (self._isInDemoMode() == False):
        # remove temp file
        try:
          os.remove(file)
        except:
          self._logError("104")


  @pyqtProperty(bool, notify = updateOrderHint)
  def showOrderHint(self):
    return self._order_hint != ""

  @pyqtProperty(str, notify = updateOrderHint)
  def orderHint(self):
    return self._order_hint

  def _showOrderHint(self, text: str, time = -1):
    self._order_hint = text
    self.updateOrderHint.emit()
    if (time > 0 ):
      threading.Timer(1, self._hideOrderHint).start()

  def _hideOrderHint(self):
    self._showOrderHint("")