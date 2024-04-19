import UIKit
import SnapKit
import Combine

final class MainViewController: UIViewController {
  
  // MARK: - UI Properties
  
  private lazy var containerView = buildContainerView()
  private lazy var titleWithNameLabel = buildRitleWithNameLabel()
  private lazy var titleLabel = buildLabel()
  private lazy var subtitleLabel = buildSubtitleLabel()
  private lazy var recommendBadgeView = buildRecommendBadgeLabel()
  private lazy var timePickerView = buildTimePickerView()
  private lazy var ctaButton = buildCTAButton()
  
  // MARK: - Instance Properties
  
  private lazy var viewModel = MainViewModel()
  private var cancellables: Set<AnyCancellable> = .init()
  
  // MARK: - View Life-Cycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupLayout()
    bind()

    viewModel.requestInitialData()
  }
}

// MARK: - Setup

private extension MainViewController {
  func setupLayout() {
    view.addSubview(containerView)
    view.addSubview(titleWithNameLabel)
    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    
    let pickerContainerView = UIView()
    pickerContainerView.addSubview(timePickerView)
    pickerContainerView.addSubview(recommendBadgeView)
    view.addSubview(pickerContainerView)
    view.addSubview(ctaButton)
    
    containerView.snp.makeConstraints { make in
      make.verticalEdges.equalTo(view.safeAreaLayoutGuide)
      make.horizontalEdges.equalToSuperview()
    }
    titleWithNameLabel.snp.makeConstraints { make in
      make.bottom.equalTo(titleLabel.snp.top).offset(-2)
      make.centerX.equalToSuperview()
    }
    titleLabel.snp.makeConstraints { make in
      make.bottom.equalTo(subtitleLabel.snp.top).offset(-12)
      make.centerX.equalToSuperview()
    }
    subtitleLabel.snp.makeConstraints { make in
      make.bottom.equalTo(pickerContainerView.snp.top).offset(-31)
      make.centerX.equalToSuperview()
    }
    pickerContainerView.snp.makeConstraints { make in
      make.height.equalTo(253)
      make.centerY.equalToSuperview()
      make.horizontalEdges.equalToSuperview().inset(40)
    }
    recommendBadgeView.snp.makeConstraints { make in
      make.width.equalTo(50)
      make.height.equalTo(CGFloat.recommentLabelHeight)
      make.left.centerY.equalToSuperview()
    }
    timePickerView.snp.makeConstraints { make in
      make.left.equalTo(recommendBadgeView.snp.right)
      make.right.verticalEdges.equalToSuperview()
    }
    ctaButton.snp.makeConstraints { make in
      make.width.equalTo(252)
      make.height.equalTo(58)
      make.top.equalTo(pickerContainerView.snp.bottom).offset(54)
      make.centerX.equalToSuperview()
    }
  }
  
  func bind() {
    viewModel.settingTimeInfoSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak self] settingTimeInfo in
        guard let self, let settingTimeInfo else { return }
        self.timePickerView.date = settingTimeInfo.date
        self.subtitleLabel.text = String(
          format: .Res.canSleepFor,
          String(settingTimeInfo.timeDiffHour),
          String(settingTimeInfo.timeDIffMinutes)
        )
        self.recommendBadgeView.textColor = settingTimeInfo.recommended ? .primary : .g4
        self.recommendBadgeView.backgroundColor = settingTimeInfo.recommended
        ? .recommendEnableColor : .recommendDisableColor
      }
      .store(in: &cancellables)
  }
}

// MARK: - Target

private extension MainViewController {
  @objc func datePickerValueChanged(_ sender: UIDatePicker) {
    viewModel.datePickerValueChanged(sender.date)
  }
}

// MARK: - Build UI Property

private extension MainViewController {
  func buildContainerView() -> UIView {
    UIView()
  }
  
  func buildRitleWithNameLabel() -> UILabel {
    let result = UILabel()
    result.font = .systemFont(ofSize: 20, weight: .semibold)
    result.numberOfLines = 1
    result.textAlignment = .center
    result.adjustsFontSizeToFitWidth = true
    result.minimumScaleFactor = 0.1
    result.textColor = .g1
    result.text = .Res.titleWithName
    return result
  }
  
  func buildLabel() -> UILabel {
    let result = UILabel()
    result.font = .systemFont(ofSize: 32, weight: .bold)
    result.numberOfLines = 1
    result.textAlignment = .center
    result.adjustsFontSizeToFitWidth = true
    result.minimumScaleFactor = 0.1
    result.textColor = .g1
    result.text = .Res.titleText
    return result
  }
  
  func buildSubtitleLabel() -> UILabel {
    let result = UILabel()
    result.font = .systemFont(ofSize: 16, weight: .regular)
    result.numberOfLines = 1
    result.textAlignment = .center
    result.adjustsFontSizeToFitWidth = true
    result.minimumScaleFactor = 0.1
    result.textColor = .subG1
    result.text = String(format: .Res.canSleepFor, String(9), String(20))
    return result
  }
    
  func buildRecommendBadgeLabel() -> UILabel {
    let result = UILabel()
    result.backgroundColor = .recommendDisableColor
    result.layer.applyCornerRadius(.recommentLabelHeight * 0.5)
    result.font = .systemFont(ofSize: 15, weight: .medium)
    result.textAlignment = .center
    result.textColor = .primary
    result.text = .Res.recommend
    return result
  }
  
  func buildTimePickerView() -> UIDatePicker {
    let result = UIDatePicker()
    result.timeZone = TimeZone.current
    result.locale = Locale.current
    result.datePickerMode = .time
    result.preferredDatePickerStyle = .wheels
    result.minuteInterval = 15
    result.isContextMenuInteractionEnabled = false
    result.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
//    if
//      let selectedDateString = self.selectedDateString,
//      selectedDateString.isNotEmpty,
//      let selectedDate = selectedDateString.toDate {
//      $0.date = selectedDate
//    }
    return result
  }
  
  func buildCTAButton() -> UIButton {
    let result = UIButton()
    result.layer.applyCornerRadius(12)
    result.backgroundColor = .primary
    result.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    result.titleLabel?.textColor = .pureWhite
    result.setTitle(.Res.startSleep, for: .normal)
    result.addAction(UIAction { [weak self] _ in
      self?.viewModel.settingAlarm()
    }, for: .touchUpInside)
    return result
  }
}

// MARK: - Const

private extension UIColor {
  static let g1 = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1)
  static let g4 = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
  static let subG1 = UIColor(red: 0.525, green: 0.565, blue: 0.612, alpha: 1)
  static let pureWhite = UIColor.white
  static let primary = UIColor(red: 0.284, green: 0.464, blue: 0.933, alpha: 1)
  static let recommendEnableColor = UIColor(red: 0.392, green: 0.612, blue: 1, alpha: 0.2)
  static let recommendDisableColor =  UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 0.2)
}

private extension CGFloat {
  static let recommentLabelHeight: CGFloat = 30
}

private extension String {
  enum Res {
    static var canSleepFor: String = {
      switch Locale.current.deviceLanguage {
      case .korean:
        return "지금 자면 %1$@시간 %2$@분 잘 수 있어요."
      default:
        return "You can sleep for %1$@hrs %2$@mins."
      }
    }()
    
    static var titleWithName: String = {
      switch Locale.current.deviceLanguage {
      case .korean:
        return "기적의 버니님,"
      default:
        return "Hello MiracleBunny,"
      }
    }()
    
    static var titleText: String = {
      switch Locale.current.deviceLanguage {
      case .korean:
        return "오늘은 푹 주무세요"
      default:
        return "Sleep tight"
      }
    }()
    
    static var recommend: String = {
      switch Locale.current.deviceLanguage {
      case .korean:
        return "추천"
      default:
        return "BEST"
      }
    }()
    
    static var startSleep: String = {
      switch Locale.current.deviceLanguage {
      case .korean:
        return "수면 시작하기"
      default:
        return "Start Sleep"
      }
    }()
  }
}
