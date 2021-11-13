import Foundation

public protocol ExpressibleByUTF8CodeUnits {
  // Originally used Sequence but changed to Collection so it works with String(decoding:as:)
  init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit
}

extension Array: ExpressibleByUTF8CodeUnits where Element == UTF8.CodeUnit {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(codeUnits)
  }
}

extension ArraySlice: ExpressibleByUTF8CodeUnits where Element == UTF8.CodeUnit {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(codeUnits)
  }
}

extension ContiguousArray: ExpressibleByUTF8CodeUnits where Element == UTF8.CodeUnit {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(codeUnits)
  }
}

extension Data: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(codeUnits)
  }
}

extension Slice: ExpressibleByUTF8CodeUnits where Base: RangeReplaceableCollection, Element == UTF8.CodeUnit {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(codeUnits)
  }
}

extension String: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(decoding: codeUnits, as: UTF8.self)
  }
}

extension String.UnicodeScalarView: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self = String(codeUnits: codeUnits).unicodeScalars
  }
}

extension String.UTF8View: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self = String(codeUnits: codeUnits).utf8
  }
}

extension Substring: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self.init(decoding: codeUnits, as: UTF8.self)
  }
}

extension Substring.UnicodeScalarView: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self = Substring(codeUnits: codeUnits).unicodeScalars
  }
}

extension Substring.UTF8View: ExpressibleByUTF8CodeUnits {
  @inlinable
  public init<C>(codeUnits: C) where C: Collection, C.Element == UTF8.CodeUnit {
    self = Substring(codeUnits: codeUnits).utf8
  }
}
