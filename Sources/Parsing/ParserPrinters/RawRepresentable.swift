extension RawRepresentable {
  @inlinable
  public static func parser() -> Parsers.RawRepresentableParser<Self> {
    .init()
  }
}

extension Parsers {
  public struct RawRepresentableParser<Output>: Parser
    where
    Output: RawRepresentable
  {
    @inlinable
    public init() {}

    @inlinable
    public func parse(_ input: inout Output.RawValue) -> Output? {
      .init(rawValue: input)
    }
  }
}

extension Parsers.RawRepresentableParser: Printer {
  @inlinable
  public func print(_ output: Output) -> Output.RawValue? {
    output.rawValue
  }
}

extension RawRepresentable where RawValue: FixedWidthInteger {
  @inlinable
  public static func parser<Input>(
    of inputType: Input.Type = Input.self,
    isSigned: Bool = true,
    radix: Int = 10,
    possibleCases: [Self]
  ) -> FixedWidthIntegerCaseParser<Input, Self> {
    .init(possibleCases: possibleCases, isSigned: isSigned, radix: radix)
  }
}

public struct StringCaseParser<Input, Output>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element == UTF8.CodeUnit,
  Output: RawRepresentable,
  Output.RawValue: StringProtocol
{
  public let possibleCases: [Output]

  @inlinable
  public init(possibleCases: [Output]) {
    self.possibleCases = possibleCases // .sorted(by: { $0.rawValue.count < $1.rawValue.count })
  }

  @inlinable
  public func parse(_ input: inout Input) -> Output? {
    for output in possibleCases {
      let rawValue = output.rawValue[...].utf8
      if input.starts(with: rawValue) {
        input.removeFirst(rawValue.count)
        return output
      }
    }
    return nil
  }
}

extension StringCaseParser: Printer where Input: AppendableCollection {
  public func print(_ output: Output) -> Input? {
    guard possibleCases.contains(where: { $0.rawValue == output.rawValue })
    else { return nil }
    var input = Input()
    input.append(contentsOf: output.rawValue.utf8)
    return input
  }
}

public struct CharacterCaseParser<Input, Output>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element == UTF8.CodeUnit,
  Output: RawRepresentable,
  Output.RawValue == Character
{
  public let possibleCases: [Output]

  @inlinable
  public init(possibleCases: [Output]) {
    self.possibleCases = possibleCases
  }

  @inlinable
  public func parse(_ input: inout Input) -> Output? {
    for output in possibleCases {
      let rawValue = output.rawValue.utf8
      if input.starts(with: rawValue) {
        input.removeFirst(rawValue.count)
        return output
      }
    }
    return nil
  }
}

extension CharacterCaseParser: Printer
  where Input: AppendableCollection
{
  public func print(_ output: Output) -> Input? {
    guard possibleCases.contains(where: { $0.rawValue == output.rawValue })
    else { return nil }
    var input = Input()
    input.append(contentsOf: output.rawValue.utf8)
    return input
  }
}

public struct FixedWidthIntegerCaseParser<Input, Output>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element == UTF8.CodeUnit,
  Output: RawRepresentable,
  Output.RawValue: FixedWidthInteger
{
  public let possibleCases: [Output]
  public let intParser: Parsers.IntParser<Input, Output.RawValue>

  @inlinable
  public init(possibleCases: [Output], isSigned: Bool = true, radix: Int = 10) {
    self.possibleCases = possibleCases
    self.intParser = Output.RawValue.parser(of: Input.self, isSigned: isSigned, radix: radix)
  }

  @inlinable
  public func parse(_ input: inout Input) -> Output? {
    let original = input
    guard let n = intParser.parse(&input) else { return nil }

    @inline(__always)
    func digits(for n: Output.RawValue) -> [Output.RawValue]? {
      var digits: [Output.RawValue] = []
      var n = n
      digits.append(n % 10)
      while n >= 10 || n <= -10 { // TODO: Fix this
        n = n / 10
        digits.append(n % 10)
      }

      return digits.reversed()
    }

//    for output in possibleCases {
//      let rawValue = output.rawValue.utf8
//      if input.starts(with: rawValue) {
//        input.removeFirst(rawValue.count)
//        return output
//      }
//    }
    return nil
  }
}

public struct FixedWidthIntegerRepresentableCaseParser<Input, Output>: Parser
  where
  Input: Collection,
  Input.SubSequence == Input,
  Input.Element == UTF8.CodeUnit,
  Output: RawRepresentable,
  Output.RawValue: FixedWidthInteger
{
  public let possibleCases: [Output]

  @inlinable
  public init(in possibleCases: [Output]) {
    self.possibleCases = possibleCases.sorted(by: { $0.rawValue < $1.rawValue })
  }

  @inlinable
  public func parse(_ input: inout Input) -> Output? {
    let rawValueParser = Output.RawValue.parser(of: Input.self)
    let original = input
    guard let n = rawValueParser.parse(&input) else { return nil }

    func digits(for n: Output.RawValue) -> [Output.RawValue] {
      var digits: [Output.RawValue] = []
      var n = n
      digits.append(n % 10)
      while n >= 10 || n <= -10 { // TODO: Fix this
        n = n / 10
        digits.append(n % 10)
      }

      return digits.reversed()
    }

    let inputDigits = digits(for: n)
    let wasSigned = inputDigits.count < original.count - input.count

    for output in possibleCases {
      let outputDigits = digits(for: output.rawValue)
      if inputDigits.starts(with: outputDigits) {
        input = original.dropFirst(wasSigned ? outputDigits.count + 1 : outputDigits.count)
        return output
      }
    }

    input = original
    return nil
  }
}

extension FixedWidthIntegerRepresentableCaseParser: Printer where Input: AppendableCollection {
  public func print(_ output: Output) -> Input? {
    let rawValueParser = Output.RawValue.parser(of: Input.self)
    return rawValueParser.print(output.rawValue)
  }
}

// inputstring:rawvalue:rest
