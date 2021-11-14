import Foundation

public protocol Appendable {
  init()
  mutating func append(contentsOf other: Self)
}

extension Appendable {
  public static func + (lhs: Self, rhs: Self) -> Self {
    var lhs = lhs
    lhs.append(contentsOf: rhs)
    return lhs
  }
}

extension Array: Appendable {}
extension ArraySlice: Appendable {}
extension ContiguousArray: Appendable {}
extension Data: Appendable {}
extension Slice: Appendable where Base: RangeReplaceableCollection {}
extension String: Appendable {}
extension String.UnicodeScalarView: Appendable {}
extension Substring: Appendable {}
extension Substring.UnicodeScalarView: Appendable {}

extension Dictionary: Appendable where Value: Appendable {
  @inlinable
  public mutating func append(contentsOf other: Self) {
    self.merge(other, uniquingKeysWith: +)
  }
}

extension String.UTF8View : Appendable {
  public init() {
    self = String().utf8
  }

  public mutating func append(contentsOf other: String.UTF8View) {
    self = String(self).appending(String(other)).utf8
  }
}

extension Substring.UTF8View : Appendable {
  public init() {
    self = Substring().utf8
  }

  public mutating func append(contentsOf other: Substring.UTF8View) {
    self = Substring(self).appending(Substring(other))[...].utf8
  }
}

