import UIKit
import SnapKit

final class CustomPickerView: UIPickerView {
  
  // MARK: - Subtypes
  
  enum PickerType: String {
    case hours
    case minutes
    case amPm
  }
  
  private var didLayoutSubviews = false
  
  let pickerType: PickerType
  
  lazy var listItem: [String] = {
    switch pickerType {
    case .hours:
      return (0...12).map { $0.formatToTwoDigits }
      
    case .minutes:
      return Array(stride(from: 0, to: 60, by: 5)).map { $0.formatToTwoDigits }
      
    case .amPm:
      switch Locale.current.deviceLanguage {
      case .korean:
        return ["오전", "오후"]
      default:
        return ["AM", "PM"]
      }
    }
  }()
  
  // MARK: - Initializers
  
  init(pickerType: PickerType) {
    self.pickerType = pickerType
    super.init(frame: .zero)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    guard !didLayoutSubviews else { return }
    didLayoutSubviews = true
    
    subviews.forEach { subview in
      subview.backgroundColor = .clear
    }
  }
}

// MARK: - Const & Util

extension Int {
  var formatToTwoDigits: String { String(format: "%02d", self) }
}
