import os.signpost

extension Parser {
  public func signpost(
    _ prefix: String = "",
    log: OSLog = OSLog(
      subsystem: "co.pointfree.swift-parsing",
      category: "Parser Instrumentation"
    )
  ) -> SignpostParser<Self> {
    SignpostParser(upstream: self, prefix: prefix, log: log)
  }
}

protocol CustomSignpostDescription {
  var signpostDescription: String { get }
}

extension Substring.UTF8View: CustomSignpostDescription {
  var signpostDescription: String {
    String(decoding: self, as: UTF8.self)
  }
}

public struct SignpostParser<Upstream>: Parser where Upstream: Parser {
  public let upstream: Upstream
  public let prefix: String
  public let log: OSLog

  public func parse(_ input: inout Upstream.Input) -> Upstream.Output? {
    // NB: Prevent rendering as "N/A" in Instruments
    let zeroWidthSpace = "\u{200B}"
    let prefix = self.prefix.isEmpty ? zeroWidthSpace : "[\(self.prefix)] "
    let sid = OSSignpostID(log: log)


    if log.signpostsEnabled {
      let inputDescription = (input as? CustomSignpostDescription)?.signpostDescription ?? String(describing: input)
      os_signpost(
        .begin,
        log: log,
        name: "Parse",
        signpostID: sid,
        "%sInput:%s",
        prefix,
        inputDescription
      )
    }
    if let output = self.upstream.parse(&input) {
      if log.signpostsEnabled {
        let restDescription = (input as? CustomSignpostDescription)?.signpostDescription ?? String(describing: input)
        let outputDescription = (output as? CustomSignpostDescription)?.signpostDescription ?? String(describing: output)
        os_signpost(
          .end,
          log: log,
          name: "Parse",
          signpostID: sid,
          "%sOutput:%s",
          prefix,
          "\(outputDescription) rest:\(restDescription)"
        )
      }
      return output
    } else {
      if log.signpostsEnabled {
        os_signpost(.end, log: log, name: "Parse", signpostID: sid, "%sFailed", prefix)
      }
      return nil
    }
  }
}
