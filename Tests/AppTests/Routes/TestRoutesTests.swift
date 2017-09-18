import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

/// This file shows an example of testing 
/// routes through the Droplet.

class RouteTests: TestCase {
    let drop = try! Droplet.testable()
    
    func testHello() throws {
        /*
        try drop
            .testResponse(to: .get, at: "hello")
            .assertStatus(is: .ok)
            .assertJSON("hello", equals: "world")
        */
    }

    func testInfo() throws {
        /*
        try drop
            .testResponse(to: .get, at: "info")
            .assertStatus(is: .ok)
            .assertBody(contains: "0.0.0.0")
        */
    }
}
