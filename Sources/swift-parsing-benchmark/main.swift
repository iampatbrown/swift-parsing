import Benchmark
import Parsing

Benchmark.main(
  [
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
    xmlSuite
  ]
)

for _ in 0..<100 {
  parseDocument()
}


