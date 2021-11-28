public struct Trim<Upstream>: Parser
  where
  Upstream: Parser,
  Upstream.Input: AppendableCollection,
  Upstream.Input.SubSequence == Upstream.Input
{
  public let upstream: Upstream

  @inlinable
  public init(upstream: Upstream) {
    self.upstream = upstream
  }

  @inlinable
  public init(@ParserBuilder _ build: () -> Upstream) {
    self.upstream = build()
  }

  @inlinable
  public func parse(_ input: inout Upstream.Input) -> Upstream.Input? {
    var rest = input
    while self.upstream.parse(&input) != nil, rest.count != input.count { // checking count to avoid infinite loop
      rest = input
    }

    var reversed = Input(input.reversed())

    while self.upstream.parse(&reversed) != nil, rest.count != reversed.count {
      rest = reversed
    }

    input.removeFirst(input.count)
    return Input(reversed.reversed())
  }
}

public struct TrimWhile<Input>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input
{
  public let predicate: (Input.Element) -> Bool

  @inlinable
  public init(_ predicate: @escaping (Input.Element) -> Bool) {
    self.predicate = predicate
  }

  @inlinable
  public func parse(_ input: inout Input) -> Input? {
    let startIndex = input.firstIndex(where: { !self.predicate($0) }) ?? input.startIndex
    var endIndex = input.endIndex
    while endIndex != startIndex {
      let previous = endIndex
      input.formIndex(&endIndex, offsetBy: -1)
      if !self.predicate(input[endIndex]) {
        endIndex = previous
        break
      }
    }
    defer { input.removeFirst(input.count) }
    return input[startIndex..<endIndex]
  }
}
