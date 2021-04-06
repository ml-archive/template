import FluentKit

extension QueryBuilder {
    @discardableResult
    func caseInsensitiveContains<Joined, Field>(
        _ schema: Joined.Type,
        _ field: KeyPath<Joined, Field>,
        _ value: Field.Value
    ) -> Self
        where Field: QueryableProperty, Field.Model == Joined, Joined: Schema
    {
        filter(Joined.path(for: field), .custom("ILIKE"), "%\(value)%")
    }

    @discardableResult
    func caseInsensitiveContains<Field>(
        _ field: KeyPath<Model, Field>,
        _ value: Field.Value
    ) -> Self
        where Field: QueryableProperty, Field.Model == Model
    {
        filter(Model.path(for: field), .custom("ILIKE"), "%\(value)%")
    }
}
