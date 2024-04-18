import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
  
  private lazy var dataLabel = buildDataLabel()
  
  private lazy var viewModel = TestViewModel(
    testUsecase: TestUsecaseImpl(repository: TestRepositoryImpl())
  )
  private var cancellables: Set<AnyCancellable> = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .green
    
    setupLayout()
    bind()
    viewModel.loadTestData()
  }
}

// MARK: - Setup

private extension ViewController {
  func setupLayout() {
    view.addSubview(dataLabel)
    dataLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  func bind() {
    viewModel.testDataSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] testData in
        print("[체크확인] - testData.count: \(testData.count)")
        guard testData.count > 0 else { return }
        self?.dataLabel.text = "testData count is \(testData.count)"
      }
      .store(in: &cancellables)
    
    viewModel.errorSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] error in
        print("[체크확인] - error: \(error)")
        self?.dataLabel.text = "에러발생: \(error.localizedDescription)"
      }
      .store(in: &cancellables)
  }
}

// MARK: - Build UI Property

private extension ViewController {
  func buildDataLabel() -> UILabel {
    let result = UILabel()
    result.font = .systemFont(ofSize: 24, weight: .bold)
    result.textColor = .white
    return result
  }
}
