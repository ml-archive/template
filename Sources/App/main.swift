import Vapor
import AppLogic

let drop = Droplet()
try setup(drop)
drop.run()
