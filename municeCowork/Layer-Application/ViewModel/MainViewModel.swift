// swiftlint:disable large_tuple
import Foundation
import Combine
import UserNotifications

final class MainViewModel {
  
  // MARK: - Subtypes
  
  struct SettingTimeInfo {
    let date: Date
    let timeDiffHour: Int
    let timeDIffMinutes: Int
    let recommended: Bool
    
    static var initialValue: SettingTimeInfo {
      .init(
        date: .init().addingTimeInterval(TimeInterval(Int.defaultSettingTimeAsSeconds)),
        timeDiffHour: 0,
        timeDIffMinutes: 0,
        recommended: false
      )
    }
    
    func logging() {
      Logg.d("date: \(date.toFormatString()) ----")
      Logg.d("timeDiffHour: \(timeDiffHour)")
      Logg.d("timeDIffMinutes: \(timeDIffMinutes)")
      Logg.d("recommended: \(recommended)")
    }
  }
  
  // MARK: - Instance Properties
  
  var settingTimeInfoSubject = CurrentValueSubject<SettingTimeInfo?, Never>(nil)
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
    let settingTimeInfo = createSettingTimeInfo(diffSeconds: .defaultSettingTimeAsSeconds, with: Date())
    settingTimeInfoSubject.send(settingTimeInfo)
  }
  
  func datePickerValueChanged(_ date: Date) {
    let currentDate = Date()
    let diff: Int
    if date > currentDate {
      diff = Int(date.timeIntervalSince(currentDate))
    } else {
      diff = .oneDayAsSeconds - Int(currentDate.timeIntervalSince(date))
    }
    let settingTimeInfo = createSettingTimeInfo(diffSeconds: diff, with: date)
    settingTimeInfo.logging()
    settingTimeInfoSubject.send(settingTimeInfo)
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
