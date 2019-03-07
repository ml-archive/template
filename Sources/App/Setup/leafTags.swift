import AdminPanel
import Leaf
import NodesSSO
import Vapor

public func leafTags(config: inout LeafTagConfig, _ container: Container) throws {
    config.useNodesSSOLeafTags()
    config.useAdminPanelLeafTags(AdminPanelUser.self)
    config.useBootstrapLeafTags()
    config.useFlashLeafTags()
    config.useResetLeafTags()
    config.useSubmissionsLeafTags()
}
