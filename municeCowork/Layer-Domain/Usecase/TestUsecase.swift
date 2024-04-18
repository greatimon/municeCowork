import Foundation
import Combine

protocol TestUsecase {
  func fetchData() async throws -> [TestModel]
}

// ----------------------------------------------------

final class TestUsecaseImpl: TestUsecase {
  
  private let repository: TestRepository
  
  init(repository: TestRepository) {
    self.repository = repository
  }
  
  func fetchData() async throws -> [TestModel] {
    do {
      let dtoList = try await repository.fetchTestData()
      return dtoList.map { dto in
        TestModel(
          id: "\(dto.userID)-\(dto.id)",
          title: dto.completed ? "Completed" : "Not Completed"
        )
      }
    } catch {
      throw error
    }
  }
}
