import Moya
import Combine

enum TestApiTargetType {
  case getTestData
}

extension TestApiTargetType: BaseMoyaTargetType {
  var path: String {
    switch self {
    case .getTestData: return NetConst.URL.PATH.TEST_API_PATH
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .getTestData: return .get
    }
  }
  
  var task: Task {
    switch self {
    case .getTestData: return .requestParameters(parameters: [:], encoding: URLEncoding.default)
//    case .getTestData: return .requestPlain
    }
  }
  
  var sampleData: Data {
    Data()
  }
}

// ----------------------------------------------------

class TestApi: BaseApi<TestApiTargetType> {
  
  static let shared = TestApi()
  private var cancelable = Set<AnyCancellable>()
  
  private override init() {}
  
  func getTestData() async throws -> [TestApiDTO] {
    let api = TestApiTargetType.getTestData
    let response = try await apiRequestAsync(api: api)
    let result = try JSONDecoder().decode([TestApiDTO].self, from: response.data)
    return result
  }
  
  private func apiRequestAsync(api: TestApiTargetType) async throws -> Response {
    do {
      return try await withCheckedThrowingContinuation { continuation in
        let cancellable = self.apiRequest(api).sink(receiveCompletion: { completion in
          if case let .failure(error) = completion {
            continuation.resume(throwing: error)
          }
        }, receiveValue: { response in
          continuation.resume(returning: response)
        })
        cancellable.store(in: &self.cancelable)
      }
    } catch {
      throw error
    }
  }
}
