import UIKit
import SnapKit

protocol TimePickerViewDelegate: AnyObject, UIPickerViewDataSource {
  func didSelectPickerView(_ timePickerComponent: TimePickerView.TimePickerComponent)
}

final class TimePickerView: UIView {

  // MARK: - Subtypes
  
  struct TimePickerComponent {
    let hour: Int
    let minute: Int
    let isAM: Bool
    
    var toDate: Date? {
      var hour = hour
      if !isAM {
        hour += 12
      }
      
      // TODO: 편의상 한국으로 고정함. 추후 올바른 UTC를 가감해서 맞춰줘야함
      let currentDateComponents = Date().toKoreaDateInRegin.dateComponents
      
      guard
        let currentYear = currentDateComponents.year,
        let currentMonth = currentDateComponents.month,
        let currentDay = currentDateComponents.day
      else { return nil }
            
      var components = DateComponents()
      components.hour = hour
      components.minute = minute
      components.year = currentYear
      components.month = currentMonth
      components.day = currentDay + 1
      
      let calendar = Calendar.current
      return calendar.date(from: components)
    }
  }
  
  // MARK: - UI Properties
  
  private lazy var hourPickerView = buildHourPickerView()
  private lazy var commaLabel = buildCommaLabel()
  private lazy var minutesPickerView = buildMinutesPickerView()
  private lazy var amPmPickerView = buildAmPmPickerView()

  // MARK: - Instance Properties
  
  private weak var viewDelegate: TimePickerViewDelegate?

  // MARK: - Initializers

  init(delegate: TimePickerViewDelegate) {
    self.viewDelegate = delegate
    super.init(frame: .zero)

    setupLayout()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Public Methods

extension TimePickerView {
  func setDate(date: Date) {
    let date = roundToNearestFiveMinutes(date: date)
    let currentDateComponents = date.toKoreaDateInRegin.dateComponents
        
    guard
      var hour = currentDateComponents.hour,
      let minute = currentDateComponents.minute
    else { return }
    
    let isAM = hour < 12
    if hour >= 12 {
      hour -= 12
    }
    
    guard
      let hourPickerIndex = hourPickerView.listItem.firstIndex(where: { $0 == hour.formatToTwoDigits }),
      let minutePickerIndex = minutesPickerView.listItem.firstIndex(where: { $0 == minute.formatToTwoDigits }),
      let amPmPickerIndex = isAM ? 0 : 1
    else { return }
    
    hourPickerView.selectRow(hourPickerIndex, inComponent: 0, animated: true)
    minutesPickerView.selectRow(minutePickerIndex, inComponent: 0, animated: true)
    amPmPickerView.selectRow(amPmPickerIndex, inComponent: 0, animated: true)
  }
}

// MARK: - Private Methods

private extension TimePickerView {
  func getCurrentTimePickerComponent(from customPickerView: CustomPickerView) -> TimePickerComponent? {
    let hourPickerViewSelectedRow = hourPickerView.selectedRow(inComponent: 0)
    let minutesPickerViewSelectedRow = minutesPickerView.selectedRow(inComponent: 0)
    let amPmPickerViewSelectedRow = amPmPickerView.selectedRow(inComponent: 0)
    
    guard
      let hour = hourPickerView.listItem[safe: hourPickerViewSelectedRow],
      let minute = minutesPickerView.listItem[safe: minutesPickerViewSelectedRow],
      let amPm = amPmPickerView.listItem[safe: amPmPickerViewSelectedRow]
    else { return nil }
    
    return TimePickerComponent(
      hour: Int(hour) ?? 0,
      minute: Int(minute) ?? 0,
      isAM: amPm == "Am" || amPm == "오전"  // TODO: 좋은 방법 아님. 추후 수정 필요
    )
  }
  
  func roundToNearestFiveMinutes(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute, .second], from: date)
    
    guard
      let hour = components.hour,
      let minute = components.minute,
      let second = components.second
    else { return date }
    
    var newMinute = (minute + 2) / 5 * 5
    var newHour = hour
    
    if newMinute >= 60 {
      newMinute -= 60
      newHour += 1
      if newHour >= 24 {
        newHour = 0
      }
    }
    
    var newComponents = DateComponents()
    newComponents.hour = newHour
    newComponents.minute = newMinute
    newComponents.second = second
    
    return calendar.date(from: newComponents) ?? date
  }
}

// MARK: - Setup Layout

private extension TimePickerView {
  func setupLayout() {
    [hourPickerView, commaLabel, minutesPickerView, amPmPickerView].forEach { view in
      addSubview(view)
    }
    
    hourPickerView.snp.makeConstraints { make in
      make.width.lessThanOrEqualTo(75)
      make.height.equalTo(CGFloat.pickerViewHeight)
      make.left.equalToSuperview().inset(CGFloat.leftMargin)
      make.verticalEdges.equalToSuperview().inset(CGFloat.verticalMargin)
    }
    commaLabel.snp.makeConstraints { make in
      make.left.equalTo(hourPickerView.snp.right).offset(12)
      make.centerY.equalToSuperview().offset(-3)
    }
    minutesPickerView.snp.makeConstraints { make in
      make.width.lessThanOrEqualTo(75)
      make.height.equalTo(CGFloat.pickerViewHeight)
      make.left.equalTo(commaLabel.snp.right).offset(12)
      make.verticalEdges.equalToSuperview().inset(CGFloat.verticalMargin)
    }
    amPmPickerView.snp.makeConstraints { make in
      make.width.lessThanOrEqualTo(70)
      make.height.equalTo(CGFloat.pickerViewHeight)
      make.left.equalTo(minutesPickerView.snp.right).offset(18.4)
      make.verticalEdges.equalToSuperview().inset(CGFloat.verticalMargin)
    }
  }
}

// MARK: - TimePickerViewDelegate

extension TimePickerView: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    guard pickerView as? CustomPickerView != nil else { return .zero }
    return 55
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    guard let customPickerView = pickerView as? CustomPickerView else { return nil }
    return customPickerView.listItem[safe: row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    guard
      let customPickerView = pickerView as? CustomPickerView,
      let timePickerComponent = getCurrentTimePickerComponent(from: customPickerView)
    else { return }
    
    viewDelegate?.didSelectPickerView(timePickerComponent)
  }
  
  func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    guard
      let customPickerView = pickerView as? CustomPickerView,
      let item = customPickerView.listItem[safe: row]
    else { return view! }
    var label = UILabel()
    if let view = view as? UILabel {
      label = view
    }
    
    switch customPickerView.pickerType {
    case .hours:
      label.font = .systemFont(ofSize: 50.12, weight: .medium)
    case .minutes:
      label.font = .systemFont(ofSize: 50.12, weight: .medium)
    case .amPm:
      label.font = .systemFont(ofSize: 32.22, weight: .medium)
    }
    
    label.textColor = .g1
    label.text = item
    label.textAlignment = .center
    label.sizeToFit()
    return label
  }
}

// MARK: - Build UI Property

private extension TimePickerView {
  func buildHourPickerView() -> CustomPickerView {
    let result = CustomPickerView(pickerType: .hours)
    result.delegate = self
    result.dataSource = viewDelegate
    return result
  }
  
  func buildCommaLabel() -> UILabel {
    let result = UILabel()
    result.font = .systemFont(ofSize: 44.75, weight: .medium)
    result.textColor = .g1
    result.text = ":"
    return result
  }
  
  func buildMinutesPickerView() -> CustomPickerView {
    let result = CustomPickerView(pickerType: .minutes)
    result.delegate = self
    result.dataSource = viewDelegate
    return result
  }
  
  func buildAmPmPickerView() -> CustomPickerView {
    let result = CustomPickerView(pickerType: .amPm)
    result.delegate = self
    result.dataSource = viewDelegate
    return result
  }
}

// MARK: - Const

private extension CGFloat {
  static let height: CGFloat = 230
  static let verticalMargin: CGFloat = 14
  static let pickerViewHeight: CGFloat = .height - (.verticalMargin * 2)
  static let leftMargin: CGFloat = 10
  static let rightMargin: CGFloat = 11
}
