import Benchmark
import Parsing

let firstNonNil = BenchmarkSuite(name: "firstNonNil") { suite in

  func firstNonNil1(fs: [() -> Int?]) -> Int? {
    for f in fs {
      if let v = f() {
        return v
      }
    }
    return nil
  }

  func firstNonNil2(fs: [() -> Int?]) -> Int? {
    for i in 0..<fs.count {
      if let v = fs[i]() {
        return v
      }
    }
    return nil
  }

  func firstNonNil3(fs: [() -> Int?]) -> Int? {
    var i = 0
    while i < fs.count {
      if let v = fs[i]() {
        return v
      }
      i += 1
    }
    return nil
  }

  let fs10: [() -> Int?] = Array(repeating: { nil }, count: 10) + [{ 42 }]
  let fs100: [() -> Int?] = Array(repeating: { nil }, count: 100) + [{ 42 }]
  let fs1000: [() -> Int?] = Array(repeating: { nil }, count: 1000) + [{ 42 }]
  let fs10000: [() -> Int?] = Array(repeating: { nil }, count: 10000) + [{ 42 }]

  suite.benchmark("firstNonNil1 10", settings: Iterations(50_000_000)) {
    let _ = firstNonNil1(fs: fs10)
  }

  suite.benchmark("firstNonNil2 10", settings: Iterations(50_000_000)) {
    let _ = firstNonNil2(fs: fs10)
  }
  

  let _0: () -> Int? = { nil }
  let _1: () -> Int? = { nil }
  let _2: () -> Int? = { nil }
  let _3: () -> Int? = { nil }
  let _4: () -> Int? = { nil }
  let _5: () -> Int? = { nil }
  let _6: () -> Int? = { nil }
  let _7: () -> Int? = { nil }
  let _8: () -> Int? = { nil }
  let _9: () -> Int? = { nil }
  let _10: () -> Int? = { 42 }



  func firstNonNilManual() -> Int? {
    if let v = _0() { return v }
    if let v = _1() { return v }
    if let v = _2() { return v }
    if let v = _3() { return v }
    if let v = _4() { return v }
    if let v = _5() { return v }
    if let v = _6() { return v }
    if let v = _7() { return v }
    if let v = _8() { return v }
    if let v = _9() { return v }
    if let v = _10() { return v }
    return nil
  }

  suite.benchmark("firstNonNil manual 10", settings: Iterations(50_000_000)) {
    let _ = firstNonNilManual()
  }

//  suite.benchmark("firstNonNil1 100") {
//    let _ = firstNonNil1(fs: fs100)
//  }
//
//  suite.benchmark("firstNonNil2 100") {
//    let _ = firstNonNil2(fs: fs100)
//  }
//
//  suite.benchmark("firstNonNil1 1000") {
//    let _ = firstNonNil1(fs: fs1000)
//  }
//
//  suite.benchmark("firstNonNil2 1000") {
//    let _ = firstNonNil2(fs: fs1000)
//  }
//
//  suite.benchmark("firstNonNil1 10000") {
//    let _ = firstNonNil1(fs: fs10000)
//  }
//
//  suite.benchmark("firstNonNil2 10000") {
//    let _ = firstNonNil2(fs: fs10000)
//  }
}

Benchmark.main(
  [
    firstNonNil,
    //    defaultBenchmarkSuite,
//    arithmeticSuite,
//    binaryDataSuite,
//    boolSuite,
//    colorSuite,
//    csvSuite,
//    dateSuite,
//    httpSuite,
//    jsonSuite,
//    numericsSuite,
//    prefixUpToSuite,
//    raceSuite,
//    readmeExampleSuite,
//    routingSuite,
//    stringAbstractionsSuite,
//    uuidSuite,
//    xcodeLogsSuite,
  ]
)
