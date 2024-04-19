import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
  
  // MARK: - Subtypes
  
  enum ListSectionType: Hashable {
    case testData
  }
  
  private lazy var dataLabel = buildDataLabel()
  private lazy var button1 = buildButton1()
  private lazy var button2 = buildButton2()
  private lazy var dividerView = buildDividerView()
  private lazy var collectionView = buildCollectionView()
  
  private lazy var viewModel = TestViewModel(
    testUsecase: TestUsecaseImpl(repository: TestRepositoryImpl()),
    testItemDataSource: makeDiffableDataSource(collectionView: collectionView)
  )
  private var cancellables: Set<AnyCancellable> = .init()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .black
    
    setupLayout()
    bind()
    viewModel.loadTestData()
  }
}

// MARK: - Private Methods

private extension ViewController {
  func scheduleNotification(at date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "Wake Up!"
    content.body = "(Calendar) It's time to wake up!"
    content.sound = UNNotificationSound.default
    
    let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { (error) in
      guard let error = error else {
        Logg.d("(Calendar) Notification scheduled successfully")
        return
      }
      Logg.e("(Calendar) Error scheduling notification: \(error.localizedDescription)")
    }
  }
  
  func scheduleNotificationSomeSecondsFromNow() {
    let notificationCenter = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = "Wake Up!"
    content.body = "(Interval) It's time to wake up!"
    content.sound = UNNotificationSound.default
    
    content.categoryIdentifier = "meetingCategory"
    let action1 = UNNotificationAction(identifier: "snoozeAction", title: "Snooze", options: [])
    let action2 = UNNotificationAction(identifier: "cancelAction", title: "Cancel", options: [.destructive])
    let category = UNNotificationCategory(
      identifier: "(some)Category",
      actions: [action1, action2],
      intentIdentifiers: [],
      options: []
    )
    notificationCenter.setNotificationCategories([category])
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    notificationCenter.add(request) { error in
      guard let error = error else {
        Logg.d("(Interval) Notification scheduled successfully")
        return
      }
      Logg.e("(Interval) Error scheduling notification: \(error.localizedDescription)")
    }
  }
  
  func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
    let configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
    configuration.scrollDirection = .vertical

    return UICollectionViewCompositionalLayout(
      sectionProvider: { [weak self] index, _ in
        guard
          let snapshot = self?.viewModel.snapshot,
          snapshot.numberOfSections >= index + 1
        else { return nil }
        return snapshot.sectionIdentifiers[index].section
      },
      configuration: configuration
    )
  }
  
  func makeDiffableDataSource(
    collectionView: UICollectionView
  ) -> UICollectionViewDiffableDataSource<ListSectionType, TestDataItem> {
    .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
      switch itemIdentifier {
      case .testData(let testData):
        let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: TestCell.reuseID,
          for: indexPath
        ) as? TestCell
        cell?.configure(testData: testData)
        return cell
      }
    }
  }
}

// MARK: - MyBrandKitsViewController.ListSectionType

private extension ViewController.ListSectionType {
  var item: NSCollectionLayoutItem {
    switch self {
    case .testData:
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .absolute(.testCellHeight)
      )
      return NSCollectionLayoutItem(layoutSize: itemSize)
    }
  }
  
  var group: NSCollectionLayoutGroup {
    switch self {
    case .testData:
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(.testCellHeight)
      )
      return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
    }
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: group)
    switch self {
    case .testData:
      section.contentInsets = .init(top: 16, leading: 20, bottom: 16, trailing: 20)
    }
    return section
  }
}

// MARK: - Setup

private extension ViewController {
  func setupLayout() {
    view.addSubview(button1)
    view.addSubview(button2)
    view.addSubview(dividerView)
    view.addSubview(dataLabel)
    view.addSubview(collectionView)
    
    button1.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
      make.centerX.equalToSuperview()
    }
    button2.snp.makeConstraints { make in
      make.top.equalTo(button1.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
    }
    dividerView.snp.makeConstraints { make in
      make.height.equalTo(6)
      make.horizontalEdges.equalToSuperview().inset(8)
      make.top.equalTo(button2.snp.bottom).offset(32)
    }
    dataLabel.snp.makeConstraints { make in
      make.top.equalTo(dividerView.snp.bottom).offset(32)
      make.centerX.equalToSuperview()
    }
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(dataLabel.snp.bottom).offset(16)
      make.horizontalEdges.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  func bind() {
    viewModel.testDataSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] testData in
        Logg.d("testData.count: \(testData.count)")
        guard testData.count > 0 else { return }
        self?.dataLabel.text = "testData count is \(testData.count)"
      }
      .store(in: &cancellables)
    
    viewModel.errorSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] error in
        Logg.e("error: \(error)")
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
  
  func buildButton1() -> UIButton {
    let result = UIButton()
    result.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    result.titleLabel?.textColor = .white
    result.setTitle("버튼1 - using Date", for: .normal)
    result.addAction(UIAction { [weak self] _ in
      self?.scheduleNotification(at: Date().addingTimeInterval(5))
    }, for: .touchUpInside)
    return result
  }
  
  func buildButton2() -> UIButton {
    let result = UIButton()
    result.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    result.titleLabel?.textColor = .white
    result.setTitle("버튼2 - using TimeInterval ", for: .normal)
    result.addAction(UIAction { [weak self] _ in
      self?.scheduleNotificationSomeSecondsFromNow()
    }, for: .touchUpInside)
    return result
  }
  
  func buildDividerView() -> UIView {
    let result = UIView()
    result.backgroundColor = .white
    return result
  }
  
  func buildCollectionView() -> UICollectionView {
    let result = UICollectionView(frame: .zero, collectionViewLayout: makeCompositionalLayout())
    result.backgroundColor = .black
    result.register(TestCell.self, forCellWithReuseIdentifier: TestCell.reuseID)
    return result
  }
}

// MARK: - Const

private extension CGFloat {
  static let testCellHeight: CGFloat = 60
}
