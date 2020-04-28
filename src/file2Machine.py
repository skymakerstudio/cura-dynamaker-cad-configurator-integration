import os.path, datetime, time, json

from cura.CuraApplication import CuraApplication
from PyQt5 import QtWidgets, QtGui
from PyQt5.QtCore import QObject, pyqtProperty, pyqtSignal, pyqtSlot, QUrl, QCoreApplication
from UM.Logger import Logger
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen

from .errorCodes import errorCodes

class Preferences():
  API_KEY = "dynamaker/file_to_machine_api_key"

class File2Machine (QObject):
  def __init__ (self, preferences):
    super().__init__()

    self._preferences = preferences
    self._preferences.addPreference(Preferences.API_KEY, "")

    self._address = "https://file2machine.com/"
    self._api_prefix = "api/"
    self._user_agent = "%s/%s " % (CuraApplication.getInstance().getApplicationName(), CuraApplication.getInstance().getVersion())

    self._api_key = ""
    self._temp_api_key = "" #typed api key not persisted to server

    self._valid_api_key = False

    self.setApiKey(self._preferences.getValue(Preferences.API_KEY))

  apiKeyUpdated = pyqtSignal()

  def _isApiKeyValid (self, api_key: str):
    _, status = self._getRequest('try-auth', api_key = api_key)
    return (status == 200)

  @pyqtSlot(str)
  def setApiKey (self, api_key: str):
    # check if key is correct
    self._temp_api_key = api_key
    self.apiKeyUpdated.emit()
    if (api_key == self._api_key): return self._valid_api_key
    
    isApiKeyValid = self._isApiKeyValid(api_key)
  
    if (isApiKeyValid):
      self._api_key = api_key
      self._preferences.setValue(Preferences.API_KEY, api_key)
    
    self._valid_api_key = isApiKeyValid
    self.apiKeyUpdated.emit()

    return self._valid_api_key

  @pyqtSlot()
  def forgetApiKey (self):
    self._api_key = ""
    self._temp_api_key = ""
    self._valid_api_key = False
    self._preferences.setValue(Preferences.API_KEY, "")
    self.apiKeyUpdated.emit()

  def _getRequest (self, apiPath: str, data = None, api_key = None, asJson = False):
    _api_key = self._api_key if api_key is None else api_key

    url = self._address + self._api_prefix + apiPath
    headers = {
      'api-key': _api_key
    }

    req = Request(url, data, headers)

    try:
      with urlopen(req) as response:
        data = response.read().decode()
        if (asJson):
          data = json.loads(data)

        status = response.getcode()
        return data, status

    except HTTPError as e:
      if (e.code != 401):
        Logger.log("w", "F2M failed to handle the request. Code: {}".format(e.code))
      return None, e.code

    except URLError as e:
      Logger.log("w", "F2M failed to handle the request. Reason: {}".format(e.reason))
      return None, 404


  def _getPublications (self):
    publications, status = self._getRequest('publications', asJson = True)
    if (status == 200):
      if (isinstance(publications, list)):
        return publications
    return []

  def getOrdersFromPublications (self, publications: list):
    fileOrders = []
  
    for publication in publications:
      for fileOrder in publication["files"]:
        if (fileOrder.get("type", "") == "stl"):
          if (fileOrder.get("meta") is not None):
            _timestamp = fileOrder.get("timestamp")
            _timestamp = "" if _timestamp is None else datetime.datetime.strptime(_timestamp, '%Y-%m-%dT%H:%M:%S.%fZ').strftime('%Y-%m-%d %H:%M:%S')
            
            _bytes = fileOrder.get("size", 0)
            _bytes = 'unknown' if (_bytes == 0) else "{}kB".format(round(int(_bytes) / 1024))

            fileOrders.append({
              "publicationId": publication["publicationId"],
              "projectTitle": publication["meta"].get("title", ""),
              "projectId": publication["meta"].get("projectId", ""),
              "application": publication["meta"].get("application", ""),
              "customerId": publication["meta"].get("customerId", ""),
              "contact": publication["meta"].get("contact", ""),
              "email": publication["meta"].get("email", ""),

              "fileId": fileOrder["id"],
              "material": fileOrder["meta"].get("material", ""),
              "quantity": fileOrder["meta"].get("quantity", ""),
              "name": fileOrder.get("name", ""),
              "type": fileOrder.get("type", ""),
              "size": _bytes,
              "timestamp": _timestamp,
            })

    return fileOrders

  def getAllFileOrders (self):
    return self.getOrdersFromPublications(self._getPublications())

  """ PtQt Exposed Properties """
  @pyqtProperty(str, notify = apiKeyUpdated)
  def apiKey (self):
    return self._api_key

  @pyqtProperty(str, notify = apiKeyUpdated)
  def tempApiKey (self):
    return self._temp_api_key

  @pyqtProperty(bool, notify = apiKeyUpdated)
  def hasValidApiKey (self):
    return self._valid_api_key

  def getFile (self, fileId: str):
    if (isinstance(fileId, str) == False):
      Logger.log("w", "f2m getFile: fileId is not a string!")
      return None

    data, status = self._getRequest('files/' + fileId)

    if (status == 200):
      return data
    
    return None