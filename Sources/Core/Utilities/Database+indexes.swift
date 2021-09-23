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

    func createIndex(for fieldKeys: FieldKey ..., onTable table: String) -> EventLoopFuture<Void> {
        fieldKeys.map { fieldKey in
            assertSQL
                .create(index: indexName(for: fieldKey, onTable: table))
                .on(table)
                .column(fieldKey.description)
                .run()
        }.flatten(on: eventLoop)
    }

    func dropIndex(for fieldKeys: FieldKey ..., onTable table: String) -> EventLoopFuture<Void> {
            fieldKeys.map { fieldKey in
                assertSQL
                    .drop(index: indexName(for: fieldKey, onTable: table))
                    .run()
            }.flatten(on: eventLoop)
    }
}
