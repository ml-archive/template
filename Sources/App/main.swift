import Vapor
import AppLogic

let drop = try Droplet()
try setup(drop)
try drop.run()
