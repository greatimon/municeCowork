import Foundation
import SwiftDate

extension Date {
  
  static let DATETIME_FORMAT_DEFALUT: String = "yyyy-MM-dd HH:mm:ss"
  static let DATETIME_FORMAT_TIL_DAY: String = "yyyy-MM-dd"

  static var today: Date {
    Date().toKoreaDateInRegin.date
  }

  var toKoreaDateInRegin: DateInRegion {
    DateInRegion(self, region: DateInRegion.REGION_KOREA)
  }
  
  func toFormatString(format: String = Date.DATETIME_FORMAT_DEFALUT) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(abbreviation: "KST")
    formatter.dateFormat = format
    return formatter.string(from: self)
  }
}

extension DateInRegion {
  static let LOCALE_KOREA: Locales = Locales.koreanSouthKorea
  static let ZONE_KOREA: Zones = Zones.asiaSeoul
  static let REGION_KOREA: Region = Region(calendar: Calendars.gregorian, zone: ZONE_KOREA, locale: LOCALE_KOREA)
}
