import Moya
import Combine

class BaseApi<API: TargetType> {
  
  private let moyaRequester = MoyaRequester<API>()
  
  func apiRequest(_ api: API) -> AnyPublisher<Response, MoyaError> {
    moyaRequester.provider.requestPublisher(api)
  }
  
  func apiTestRequest(_ api: API) -> AnyPublisher<Response, MoyaError> {
    moyaRequester.testProvider.requestPublisher(api)
  }
}
