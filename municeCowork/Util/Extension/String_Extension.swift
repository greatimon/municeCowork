import Foundation

extension String {
  func replace(_ originalString: String, newString: String) -> String {
    return self.replacingOccurrences(
      of: originalString,
      with: newString,
      options: NSString.CompareOptions.literal,
      range: nil
    )
  }
}
