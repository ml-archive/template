#if os(Linux)

import XCTest
@testable import AppTests

// sourcery:inline:auto:LinuxMain

extension PostControllerTests {
  static var allTests = [
    ("testPostRoutes", testPostRoutes),
  ]
}

extension RouteTests {
  static var allTests = [
    ("testHello", testHello),
    ("testInfo", testInfo),
  ]
}

XCTMain([
  testCase(PostControllerTests.allTests),
  testCase(RouteTests.allTests),
])
  
// sourcery:end

#endif
