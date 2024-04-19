import Foundation

enum TestDataItem {
  case testData(testData: TestModel)
}

extension TestDataItem: Hashable {
  static func == (lhs: TestDataItem, rhs: TestDataItem) -> Bool {
    switch (lhs, rhs) {
    case (.testData(let lhsTestData), .testData(let rhsTestData)):
      return lhsTestData.id == rhsTestData.id
    }
  }

  func hash(into hasher: inout Hasher) {
    switch self {
    case .testData(let testData):
      hasher.combine(testData.id)
    }
  }
}
