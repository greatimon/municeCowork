import Foundation
import Combine

final class TestViewModel {
  
  var testDataSubject = CurrentValueSubject<[TestModel], Never>([])
  var errorSubject = PassthroughSubject<Error, Never>()
  
  private let testUsecase: TestUsecase
  private var loadTestDataTask: Task<Void, Never>?
  
  init(testUsecase: TestUsecase) {
    self.testUsecase = testUsecase
  }
  
  deinit {
    loadTestDataTask?.cancel()
  }
}

// MARK: - Public Methods

extension TestViewModel {
  func loadTestData() {
    loadTestDataTask = Task { [weak self] in
      do {
        guard let data = try await self?.testUsecase.fetchData() else { return }
        data.forEach { testModel in Logg.i("testModel - \(testModel.id) / \(testModel.title)") }
        self?.testDataSubject.send(data)
      } catch {
        print("Failed to load data with error: \(error)")
        self?.errorSubject.send(error)
      }
    }
  }
}
