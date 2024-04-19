import Foundation

extension Locale {
  enum DeviceLanguage: String {
    case english = "en"
    case korean = "ko"
    case others = ""
  }
  
  var deviceLanguage: DeviceLanguage {
    guard let languageCode = Locale.preferredLocale.languageCode?.lowercased() else { return .others }
    Logg.i("languageCode: \(languageCode)")
    return DeviceLanguage(rawValue: languageCode) ?? .others
  }
  
  private static var preferredLocale: Locale {
    guard let preferredIdentifier = Locale.preferredLanguages.first else {
      return Locale.current
    }
    return Locale(identifier: preferredIdentifier)
  }
}
