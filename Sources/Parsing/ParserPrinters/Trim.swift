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
