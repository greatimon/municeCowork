// swiftlint:disable unused_optional_binding
import Moya

class RequestCustomLogPlugin: PluginType {
  func willSend(_ request: RequestType, target: TargetType) {
    Logg.d("------------------------------------- willSend ------------------------------------------")
    guard let httpRequest = request.request else {
      print("-------------- willSend --------------> invalid request")
      return
    }
    
    let url = httpRequest.description
    let method = httpRequest.httpMethod ?? "unknown method"
    
    var log = "-------------- willSend --------------> \(method) \(url)\n"
    log.append("API: \(target)\n")
    
    if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
      log.append("header: \(headers)\n")
    }
    
    if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
      log.append("\(bodyString)\n")
    }
    
    log.append("-------------- willSend --------------> END \(method)")
    print(log)
  }
  
  func didReceive(_ result: Swift.Result<Moya.Response, MoyaError>, target: TargetType) {
    Logg.d("------------------------------------- didReceive -----------------------------------------")
    switch result {
    case let .success(response):
      onSuceed(response, target: target, isFromError: false)
    case let .failure(error):
      onFail(error, target: target)
    }
  }
  
  private func onSuceed(_ response: Moya.Response, target: TargetType, isFromError: Bool) {
    Logg.d("------------------------------------- onSuceed ------------------------------------------")
    let request = response.request
    let url = request?.url?.absoluteString ?? "nil"
    let statusCode = response.statusCode
    
    var log = "<-------------- onSuceed -------------- \(statusCode) \(url)\n"
    log.append("API: \(target)\n")
    
    response.response?.allHeaderFields.forEach {
      log.append("\($0): \($1)\n")
    }
    
    if let _ = String(bytes: response.data, encoding: String.Encoding.utf8) {
      // response data 보려면 아래 주석 해제하기
      // log.append("\(reString)\n")
    }
    
    log.append("<-------------- onSuceed -------------- END HTTP (\(response.data.count)-byte body)")
    print(log)
  }
  
  private func onFail(_ moyaError: MoyaError, target: TargetType) {
    Logg.d("------------------------------------- onFail --------------------------------------------")
    if let response = moyaError.response {
      onSuceed(response, target: target, isFromError: true)
      return
    }
    
    var log = "<-------------- onFail -------------- \(moyaError.errorCode) \(target)\n"
    log.append("\(moyaError.localizedDescription)\n")
    log.append("<-------------- onFail -------------- END HTTP")
    print(log)
  }
}
// swiftlint:enable unused_optional_binding
