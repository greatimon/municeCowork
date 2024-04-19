import Foundation
import UIKit
import Combine

final class TestViewModel {
  
  // MARK: - Subtypes

  typealias ListSectionType = ViewController.ListSectionType
  typealias TestItemDataSource = UICollectionViewDiffableDataSource<ListSectionType, TestDataItem>
  
  // MARK: - Instance Properties
  
  var testDataSubject = CurrentValueSubject<[TestModel], Never>([])
  var errorSubject = PassthroughSubject<Error, Never>()
  
  private let testUsecase: TestUsecase
  private let diffableDataSource: TestItemDataSource
  private var loadTestDataTask: Task<Void, Never>?
  
  init(testUsecase: TestUsecase, testItemDataSource: TestItemDataSource) {
    self.testUsecase = testUsecase
    diffableDataSource = testItemDataSource
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
        await self?.applyData(data.map { .testData(testData: $0) }, animatingDifferences: true)
        self?.testDataSubject.send(data)
      } catch {
        print("Failed to load data with error: \(error)")
        self?.errorSubject.send(error)
      }
    }
  }
  
  var snapshot: NSDiffableDataSourceSnapshot<ListSectionType, TestDataItem>? {
    diffableDataSource.snapshot()
  }
}

// MARK: - Private Methods

extension TestViewModel {
  func applyData(_ dataItemList: [TestDataItem], animatingDifferences: Bool) async {
    await MainActor.run {
      var snapshot = NSDiffableDataSourceSnapshot<ListSectionType, TestDataItem>()
      snapshot.appendSections([.testData])
      snapshot.appendItems(dataItemList, toSection: .testData)

      diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
  }
}
