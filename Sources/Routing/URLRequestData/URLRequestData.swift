import Foundation
import Parsing

public struct URLRequestData: Equatable, Appendable {
  public var body: ArraySlice<UInt8>?
  public var headers: [String: Substring]
  public var method: String?
  public var path: ArraySlice<Substring>
  public var query: [String: ArraySlice<Substring?>]

  @inlinable
  public init() {
    self.method = nil
    self.path = []
    self.query = [:]
    self.headers = [:]
    self.body = nil
  }

  @inlinable
  public init(
    method: String? = nil,
    path: ArraySlice<Substring> = [],
    query: [String: ArraySlice<Substring?>] = [:],
    headers: [String: Substring] = [:],
    body: ArraySlice<UInt8>? = nil
  ) {
    self.method = method
    self.path = path
    self.query = query
    self.headers = headers
    self.body = body
  }

  @inlinable
  public mutating func append(contentsOf other: URLRequestData) {
    self.headers.append(contentsOf: other.headers)
    self.method = self.method ?? other.method
    self.path.append(contentsOf: other.path)
    self.query.append(contentsOf: other.query)
    guard other.body != nil else { return }
    if self.body != nil {
      self.body!.append(contentsOf: other.body!)
    } else {
      self.body = other.body
    }
  }
}
