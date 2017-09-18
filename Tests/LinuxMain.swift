#if os(Linux)

import XCTest
@testable import AppTests

// sourcery:inline:auto:LinuxMain

XCTMain([
    testCase(PostControllerTests.allTests),
    testCase(RouteTests.allTests)
])
  
// sourcery:end

#endif
