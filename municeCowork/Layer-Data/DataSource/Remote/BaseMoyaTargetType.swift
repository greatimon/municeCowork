import Moya

protocol BaseMoyaTargetType: TargetType { }

extension BaseMoyaTargetType {
  var baseURL: URL {
    URL(string: NetConst.URL.BASE_URL)!
  }
  
  var headers: [String: String]? {
    [
      "Content-Type": "application/json;charset=UTF8",
      "Accept": "application/json"
    ]
  }
}
