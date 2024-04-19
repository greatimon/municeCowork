import Foundation

protocol ReuseIdentifierable { }

extension ReuseIdentifierable {
  static var reuseID: String { String(describing: self) }
}
