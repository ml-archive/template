import AdminPanel
import Leaf
import NodesSSO
import Vapor

func leafTags(config: inout LeafTagConfig) throws {
    config.useAdminPanelLeafTags(AdminPanelUser.self)
    config.useBootstrapLeafTags()
    config.useFlashLeafTags()
    config.useNodesSSOLeafTags()
    config.useResetLeafTags()
    config.useSubmissionsLeafTags()
}
