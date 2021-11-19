import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLRequestData {
  public init?(request: URLRequest) {
    guard
      let url = request.url,
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { return nil }

    self.init(
      method: request.httpMethod,
      path: url.path.split(separator: "/")[...],
      query: components.queryItems?.reduce(into: [:]) { query, item in
        query[item.name, default: []].append(item.value?[...])
      } ?? [:],
      headers: request.allHTTPHeaderFields?.mapValues { $0[...] } ?? [:],
      body: request.httpBody.map { ArraySlice($0) }
    )
  }

  public init?(url: URL) {
    self.init(request: URLRequest(url: url))
  }

  public init?(string: String) {
    guard let url = URL(string: string)
    else { return nil }
    self.init(url: url)
  }
}

extension URLRequest {
  init?(data: URLRequestData) {
    self.init(data: data, base: nil)
  }

  init?(data: URLRequestData, base: URL?) {
    guard
      let url = data.path.isEmpty && data.query.isEmpty
      ? (base ?? URL(string: "/"))
      : urlComponents(from: data).url(relativeTo: base)
    else { return nil }
    self.init(url: url)
    self.httpMethod = data.method
    self.httpBody = data.body.map(Data.init)
    self.allHTTPHeaderFields = data.headers.mapValues(String.init)
  }
}

private func urlComponents(from data: URLRequestData) -> URLComponents {
  var components = URLComponents()
  components.path = data.path.joined(separator: "/")
  let query = data.query.mapValues { $0.compactMap { $0 }.joined() }.filter { !$0.value.isEmpty }
  if !query.isEmpty {
    components.queryItems = query.map(URLQueryItem.init(name:value:))
  }
  return components
}
