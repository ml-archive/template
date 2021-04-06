import FluentSQL
import Vapor

extension Database {
    private var assertSQL: SQLDatabase {
        guard let sql = self as? SQLDatabase else {
            fatalError("Cannot create index on non-SQL database")
        }
        return sql
    }

    func indexName(for fieldKey: FieldKey, onTable table: String) -> String {
        "\(table)_\(fieldKey)_idx"
    }

    func createIndex(for fieldKey: FieldKey, onTable table: String) -> EventLoopFuture<Void> {
        assertSQL
            .create(index: indexName(for: fieldKey, onTable: table))
            .on(table)
            .column(fieldKey.description)
            .run()
    }

    func dropIndex(for fieldKey: FieldKey, onTable table: String) -> EventLoopFuture<Void> {
        assertSQL
            .drop(index: indexName(for: fieldKey, onTable: table))
            .run()
    }
}
