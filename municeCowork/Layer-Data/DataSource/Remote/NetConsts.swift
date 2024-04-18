import Foundation

struct NetConst {
  
  struct Policy {
    static let REQUEST_RETRY_COUNT = 3
    static let REQUEST_RETRY_TIMEOUT = 10
    static let RESOURCE_RETRY_TIMEOUT = 10
  }
  
  struct URL {
    static let BASE_URL = "https://jsonplaceholder.typicode.com"
    
    struct PATH {
      static let TEST_API_PATH = "/todos"
    }
  }
}
