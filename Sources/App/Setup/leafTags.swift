import AdminPanel
import Leaf
import NodesSSO
import Vapor

public func leafTags(config: inout LeafTagConfig, _ container: Container) throws {
    config.useNodesSSOLeafTags()
    try config.useAdminPanelLeafTags(AdminPanelUser.self, on: container)
    config.useBootstrapLeafTags()
    config.useFlashLeafTags()
    config.useResetLeafTags()
    try config.useSubmissionsLeafTags(on: container)
}
