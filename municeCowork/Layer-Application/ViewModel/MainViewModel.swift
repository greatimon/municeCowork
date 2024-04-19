// swiftlint:disable large_tuple
import Foundation
import Combine
import UserNotifications
import UIKit

final class MainViewModel: NSObject {
  
  // MARK: - Subtypes
  
  struct SettingTimeInfo {
    let date: Date
    let timeDiffHour: Int
    let timeDIffMinutes: Int
    let recommended: Bool
  }
  
  // MARK: - Instance Properties
  
  var settingTimeInfoSubject = CurrentValueSubject<(data: SettingTimeInfo, needToUpdatePicker: Bool)?, Never>(nil)
}

// MARK: - Private Methods

private extension MainViewModel {
  func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
  }
  
  func isWithinTargetRange(seconds: Int) -> Bool {
    let targetInterval: Int = .cycleTimeAsSeconds
    let tolerance: Int = .inCycleMinutesAsSeconds
    let remainder = seconds % targetInterval
    return remainder <= tolerance || (targetInterval - remainder) <= tolerance
  }

  func createSettingTimeInfo(diffSeconds: Int, with date: Date) -> SettingTimeInfo {
    let diffAsSeconds = diffSeconds.secondsToHoursMinutesSeconds
    let isInCycle = isWithinTargetRange(seconds: diffSeconds)
    
    return .init(
      date: date,
      timeDiffHour: diffAsSeconds.hour,
      timeDIffMinutes: diffAsSeconds.minutes,
      recommended: isInCycle
    )
  }
}

// MARK: - Public Methods

extension MainViewModel {
  func settingAlarm() {
    requestInitialData()
  }
  
  func requestInitialData() {
    let currentDate: Date = .init()
    let initialAlarmDate: Date = currentDate.addingTimeInterval(TimeInterval(Int.defaultSettingTimeAsSeconds))
    let diff: Int = Int(initialAlarmDate.timeIntervalSince(currentDate))
    
    let settingTimeInfo = createSettingTimeInfo(diffSeconds: diff, with: initialAlarmDate)

    settingTimeInfoSubject.send((data: settingTimeInfo, needToUpdatePicker: true))
  }
  
  func datePickerValueChanged(_ date: Date, needToUpdatePicker: Bool) {
    let currentDate = Date()
    let diff: Int
    if date > currentDate {
      diff = Int(date.timeIntervalSince(currentDate))
    } else {
      diff = .oneDayAsSeconds - Int(currentDate.timeIntervalSince(date))
    }
    let settingTimeInfo = createSettingTimeInfo(diffSeconds: diff, with: date)
    settingTimeInfoSubject.send((data: settingTimeInfo, needToUpdatePicker: needToUpdatePicker))
  }
}

// MARK: - TimePickerViewDelegate

extension MainViewModel: TimePickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }
  
  func pickerView(
    _ pickerView: UIPickerView,
    numberOfRowsInComponent component: Int
  ) -> Int {
    guard let customPickerView = pickerView as? CustomPickerView else { return .zero }
    return customPickerView.listItem.count
  }
  
  func didSelectPickerView(_ timePickerComponent: TimePickerView.TimePickerComponent) {
    guard let date = timePickerComponent.toDate else { return }
    datePickerValueChanged(date, needToUpdatePicker: false)
  }
}

// MARK: - Const

private extension Int {
  static let defaultSettingTimeAsSeconds: Int = 60 * 60 * 6
  static let oneDayAsSeconds: Int = 60 * 60 * 24
  static let cycleTimeAsSeconds: Int = 60 * 90
  static let inCycleMinutesAsSeconds: Int = 10 * 60
  
  var secondsToHoursMinutesSeconds: (hour: Int, minutes: Int, seconds: Int) {
    (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
  }
}
// swiftlint:enable large_tuple
