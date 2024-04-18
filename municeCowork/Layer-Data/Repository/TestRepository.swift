import Foundation
import Combine
import Moya

protocol TestRepository {
  func fetchTestData() async throws -> [TestApiDTO]
}

final class TestRepositoryImpl: TestRepository {
  
  private let apiService = TestApi.shared
  
  func fetchTestData() async throws -> [TestApiDTO] {
    do {
      return try await apiService.getTestData()
    } catch {
      throw error
    }
  }
}
