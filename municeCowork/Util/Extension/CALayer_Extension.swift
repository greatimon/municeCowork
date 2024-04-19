import UIKit

extension CALayer {
  func applyCornerRadius(_ radius: CGFloat) {
    masksToBounds = true
    cornerCurve = .continuous
    cornerRadius = radius
  }
}
