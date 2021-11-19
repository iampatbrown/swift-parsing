import Foundation

// TODO: Temp from swift-web

@usableFromInline
func urlFormEncode<A: Encodable>(value: A) -> String {
  return (try? JSONEncoder().encode(value))
    .flatMap { try? JSONSerialization.jsonObject(with: $0) }
    .flatMap { $0 as? [String: Any] }
    .map(urlFormEncode(value:))
    ?? ""
}

@usableFromInline
func urlFormEncode(values: [Any], rootKey: String) -> String {
  return urlFormEncode(values: values, rootKey: rootKey, keyConstructor: { $0 })
}

@usableFromInline
func urlFormEncode(value: [String: Any]) -> String {
  return urlFormEncode(value: value, keyConstructor: { $0 })
}

@usableFromInline
func urlFormEncode(values: [Any], rootKey: String, keyConstructor: (String) -> String) -> String {
  return values.enumerated()
    .map { idx, value in
      switch value {
      case let value as [String: Any]:
        return urlFormEncode(value: value, keyConstructor: { "\(keyConstructor(rootKey))[\(idx)][\($0)]" })

      case let values as [Any]:
        return urlFormEncode(
          values: values, rootKey: "", keyConstructor: { _ in "\(keyConstructor(rootKey))[\(idx)]" }
        )

      default:
        return urlFormEncode(value: value, keyConstructor: { _ in "\(keyConstructor(rootKey))[\(idx)]" })
      }
    }
    .joined(separator: "&")
}

@usableFromInline
func urlFormEncode(value: Any, keyConstructor: (String) -> String) -> String {
  guard let dictionary = value as? [String: Any] else {
    let encoded = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryParamAllowed) ?? value
    return "\(keyConstructor(""))=\(encoded)"
  }

  return dictionary
    .sorted(by: { $0.key < $1.key })
    .map { key, value in
      switch value {
      case let value as [String: Any]:
        return urlFormEncode(value: value, keyConstructor: { "\(keyConstructor(key))[\($0)]" })

      case let values as [Any]:
        return urlFormEncode(values: values, rootKey: key, keyConstructor: keyConstructor)

      default:
        return urlFormEncode(value: value, keyConstructor: { _ in keyConstructor(key) })
      }
    }
    .joined(separator: "&")
}

extension CharacterSet {
  @usableFromInline
  static let urlQueryParamAllowed = CharacterSet.urlQueryAllowed
    .subtracting(.init(charactersIn: ":#[]@!$&'()*+,;="))
}
