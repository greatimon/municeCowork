import Moya
import Alamofire

class MoyaRequester<T: TargetType> {
  
  private lazy var networkClosure = {(_ changeType: NetworkActivityChangeType, _ target: TargetType) in
    switch changeType {
    case .began:
      break
    case .ended:
      break
    }
  }
  
  private lazy var session: Session = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = TimeInterval(NetConst.Policy.REQUEST_RETRY_TIMEOUT)
    configuration.timeoutIntervalForResource = TimeInterval(NetConst.Policy.RESOURCE_RETRY_TIMEOUT)
    
    let interceptor = Interceptor(adapters: [],
                                  retriers: [getRetryPolicy()],
                                  interceptors: [AuthTokenInterceptor()])
    
    return Session(configuration: configuration, interceptor: interceptor)
  }()
  
  private func getRetryPolicy() -> RetryPolicy {
    RetryPolicy(retryLimit: UInt(NetConst.Policy.REQUEST_RETRY_COUNT))
  }
  
  lazy var provider = MoyaProvider<T>(
    session: session,
    plugins: [
      RequestCustomLogPlugin(),   // 참고로, Moya 기본 제공 로깅 플러그인은 'NetworkLoggerPlugin'
      NetworkActivityPlugin(networkActivityClosure: networkClosure)
    ]
  )
  
  // -------------------------------- 이 이하, api 테스트 MoyaProvider ----------------------------------------
  
  private let customEndpointClosureForTest = { (target: T) -> Endpoint in
    Endpoint(
      url: URL(target: target).absoluteString,
      // success response 리턴
      sampleResponseClosure: { .networkResponse(200, target.sampleData) },
      // error response 리턴
      // sampleResponseClosure: { .networkError(NSError(domain: "강제 에러", code: 400, userInfo: nil)) },
      method: target.method,
      task: target.task,
      httpHeaderFields: target.headers
    )
  }
  
  lazy var testProvider = MoyaProvider<T>(
    endpointClosure: customEndpointClosureForTest,
    stubClosure: MoyaProvider.immediatelyStub,
    plugins: [RequestCustomLogPlugin(), NetworkActivityPlugin(networkActivityClosure: networkClosure)]
  )
}

class AuthTokenInterceptor: RequestInterceptor {
  func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) {
    print("AuthTokenInterceptor adapt..")
    
    var urlRequest = urlRequest
    urlRequest.headers.add(name: "Authorization", value: "some token")
    
    print("urlRequest.headers['Authorization']: \(urlRequest.headers["Authorization"] ?? "")")
    completion(.success(urlRequest))
  }
}
