// swiftlint:disable identifier_name cyclomatic_complexity
import Foundation
import os.log

extension OSLog {
  static let subsystem = "무니스코웤"
  static let error = OSLog(subsystem: subsystem, category: "Error")
  static let info = OSLog(subsystem: subsystem, category: "Info")
  static let network = OSLog(subsystem: subsystem, category: "Network")
  static let debug = OSLog(subsystem: subsystem, category: "Debug")
  static let ui = OSLog(subsystem: subsystem, category: "UI")
}

// --------------------------------------------------------------------------------------------------------

struct Logg {
  
  enum Level {
    case error
    case info
    case network
    case debug
    case ui
    case custom(categoryName: String)
    
    fileprivate var category: String {
      switch self {
      case .error:
        return "Error"
      case .info:
        return "Info"
      case .network:
        return "Network"
      case .debug:
        return "Debug"
      case .ui:
        return "UI"
      case .custom(let categoryName):
        return categoryName
      }
    }
    
    fileprivate var categoryEmoji: String {
      switch self {
      case .error:
        return "❌"
      case .info:
        return "ℹ️"
      case .network:
        return "📶"
      case .debug:
        return "✅"
      case .ui:
        return "🖥"
      case .custom:
        return "⚙️"
      }
    }
    
    fileprivate var osLog: OSLog {
      switch self {
      case .error:
        return OSLog.error
      case .info:
        return OSLog.info
      case .network:
        return OSLog.network
      case .debug:
        return OSLog.debug
      case .ui:
        return OSLog.debug
      case .custom:
        return OSLog.debug
      }
    }
    
    fileprivate var osLogType: OSLogType {
      switch self {
      case .error:
        return .error
      case .info:
        return .info
      case .network:
        return .default
      case .debug:
        return .debug
      case .ui:
        return .debug
      case .custom:
        return .debug
      }
    }
  }
  
  // ------------------------------------------------
  
  private static let showMethod = false
  private static let showFileName = true
  
  private static var isEnableLog: Bool {
    return true
  }
  
  // ------------------------------------------------
  
  private static func log(_ message: Any, level: Logg.Level, _ function: String, _ filePath: String, _ fileLine: Int) {
    guard isEnableLog else { return }
    
    let logMessage: String
    if showMethod {
      if showFileName {
        if let messageStr = message as? String, messageStr.isEmpty {
          logMessage = "\(level.categoryEmoji) \(getFileName(filePath))::\(fileLine) - \(function)"
        } else {
          logMessage = "\(level.categoryEmoji) \(getFileName(filePath))::\(fileLine) - \(function) => \(message)"
        }
      } else {
        if let messageStr = message as? String, messageStr.isEmpty {
          logMessage = "\(level.categoryEmoji): \(fileLine) - \(function)"
        } else {
          logMessage = "\(level.categoryEmoji): \(fileLine) - \(function) => \(message)"
        }
      }
    } else {
      if showFileName {
        if let messageStr = message as? String, messageStr.isEmpty {
          logMessage = "\(level.categoryEmoji) \(getFileName(filePath))::\(fileLine)"
        } else {
          logMessage = "\(level.categoryEmoji) \(getFileName(filePath))::\(fileLine) => \(message)"
        }
      } else {
        if let messageStr = message as? String, messageStr.isEmpty {
          logMessage = "\(level.categoryEmoji) ::\(fileLine)"
        } else {
          logMessage = "\(level.categoryEmoji) ::\(fileLine) => \(message)"
        }
      }
    }
    
    if #available(iOS 14.0, *) {
      let logger = Logger(subsystem: OSLog.subsystem, category: level.category)
      switch level {
      case .error:
        logger.error("\(logMessage, privacy: .public)")
      case .info:
        logger.info("\(logMessage, privacy: .public)")
      case .network:
        logger.log("\(logMessage, privacy: .public)")
      case .debug:
        logger.debug("\(logMessage, privacy: .public)")
      case .ui:
        logger.debug("\(logMessage, privacy: .public)")
      case .custom:
        logger.debug("\(logMessage, privacy: .public)")
      }
    } else {
      os_log("%{public}@", log: level.osLog, type: level.osLogType, "\(logMessage)")
    }
  }
  
  private static func getFileName(_ filePath: String) -> String {
    var fileName = NSURL(fileURLWithPath: filePath).lastPathComponent! as String
    fileName = fileName.replace(".swift", newString: "")
    fileName = fileName.replace("ViewController", newString: "")
    fileName = fileName.replace("JustForLog_Extension", newString: "")
    return fileName
  }
}

// MARK: - static func
extension Logg {
  static func e(_ message: Any, function: String = #function, filePath: String = #file, fileLine: Int = #line) {
    log(message, level: .error, function, filePath, fileLine)
  }
  
  static func i(_ message: Any, function: String = #function, filePath: String = #file, fileLine: Int = #line) {
    log(message, level: .info, function, filePath, fileLine)
  }
  
  static func net(_ message: Any, function: String = #function, filePath: String = #file, fileLine: Int = #line) {
    log(message, level: .network, function, filePath, fileLine)
  }
  
  static func d(_ message: Any, function: String = #function, filePath: String = #file, fileLine: Int = #line) {
    log(message, level: .debug, function, filePath, fileLine)
  }
  
  static func ui(_ message: Any, function: String = #function, filePath: String = #file, fileLine: Int = #line) {
    log(message, level: .ui, function, filePath, fileLine)
  }
  
  static func custom(
    category: String,
    _ message: Any,
    function: String = #function,
    filePath: String = #file,
    fileLine: Int = #line
  ) {
    log(message, level: .custom(categoryName: category), function, filePath, fileLine)
  }
}
// swiftlint:enable identifier_name cyclomatic_complexity
