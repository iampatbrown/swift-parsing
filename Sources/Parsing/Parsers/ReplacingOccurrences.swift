public struct ReplacingOccurrences<Input>: Parser
  where Input: AppendableCollection,
  Input.SubSequence == Input
{
  public let target: Input
  public let replacement: Input
  public let areEquivalent: (Input.Element, Input.Element) -> Bool

  @inlinable
  public init(
    of target: Input,
    with replacement: Input,
    // could add subrange and maxReplacements
    by areEquivalent: @escaping (Input.Element, Input.Element) -> Bool
  ) {
    self.target = target
    self.replacement = replacement
    self.areEquivalent = areEquivalent
  }

  @inlinable
  public func parse(_ input: inout Input) -> Input? {
    guard let targetFirst = self.target.first else {
      defer { input.removeFirst(input.count) }
      return input
    }

    let buffer = Array(input)
    var result = [Input.Element]()
    var currentIndex = 0

    @inline(__always)
    func nextMatch() -> Range<Int>? {
      var searchStart = currentIndex
      while let matchStart = buffer[searchStart...].firstIndex(where: { self.areEquivalent($0, targetFirst) }) {
        var bufferIndex = matchStart
        var targetIndex = self.target.startIndex

        repeat {
          buffer.formIndex(after: &bufferIndex)
          self.target.formIndex(after: &targetIndex)

          if targetIndex == self.target.endIndex {
            return matchStart..<bufferIndex
          } else if bufferIndex == buffer.endIndex {
            return nil
          }
        } while self.areEquivalent(buffer[bufferIndex], self.target[targetIndex])

        searchStart = buffer.index(after: matchStart)
      }
      return nil
    }

    while let match = nextMatch() {
      result.append(contentsOf: buffer[currentIndex..<match.lowerBound])
      result.append(contentsOf: self.replacement)
      currentIndex = match.upperBound
    }

    result.append(contentsOf: buffer[currentIndex...])
    input.removeFirst(input.count)
    return Input(result)
  }
}
