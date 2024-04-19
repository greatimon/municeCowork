import UIKit
import SnapKit
import Combine

class ViewController: UIViewController {
  
  private lazy var dataLabel = buildDataLabel()
  private lazy var button1 = buildButton1()
  private lazy var button2 = buildButton2()
  
  private lazy var viewModel = TestViewModel(
    testUsecase: TestUsecaseImpl(repository: TestRepositoryImpl())
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
}

// MARK: - Setup

private extension ViewController {
  func setupLayout() {
    view.addSubview(dataLabel)
    view.addSubview(button1)
    view.addSubview(button2)
    
    dataLabel.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
      make.centerX.equalToSuperview()
    }
    button1.snp.makeConstraints { make in
      make.top.equalTo(dataLabel.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
    }
    button2.snp.makeConstraints { make in
      make.top.equalTo(button1.snp.bottom).offset(16)
      make.centerX.equalToSuperview()
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
}
