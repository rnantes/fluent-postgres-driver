import PostgresNIO
import PostgresKit
import FluentKit
import SQLKit

extension SQLRow {
//    internal func databaseOutput(using decoder: PostgresDataDecoder, columnOverflowAliasDict: [String:String] = [:]) -> DatabaseOutput {
//        _PostgresDatabaseOutput(
//            row: self,
//            decoder: decoder,
//            columnOverflowAliasDict: columnOverflowAliasDict
//        )
//    }
//    
    internal func databaseOutput(columnOverflowAliasDict: [String:String] = [:]) -> some DatabaseOutput { _PostgresDatabaseOutput(row: self, schema: nil, columnOverflowAliasDict: columnOverflowAliasDict) }
}

private struct _PostgresDatabaseOutput: DatabaseOutput {
    let row: any SQLRow
    let schema: String?
    
    let columnOverflowAliasDict: [String:String]
    
    init(row: any SQLRow, schema: String?, columnOverflowAliasDict: [String:String] = [:]) {
        self.row = row
        self.schema = schema
        self.columnOverflowAliasDict = columnOverflowAliasDict
    }
    
    var description: String {
        String(describing: self.row)
    }

    func schema(_ schema: String) -> DatabaseOutput {
        _SchemaDatabaseOutput(output: self, schema: schema)
    }

    func contains(_ key: FieldKey) -> Bool {
        self.row.contains(column: self.columnName(key))
    }

    func decodeNil(_ key: FieldKey) throws -> Bool {
        try self.row.decodeNil(column: self.columnName(key))
    }

    func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T: Decodable {
        try self.row.decode(column: self.columnName(key), as: T.self)
    }

    private func columnName(_ key: FieldKey) -> String {
        switch key {
        case .id:
            return "id"
        case .aggregate:
            return key.description
        case .string(let name):
            if let nameAliased = columnOverflowAliasDict[name] {
                return nameAliased
            }
            return name
        case .prefix(let prefix, let key):
            let name = self.columnName(prefix) + self.columnName(key)
            if let nameAliased = columnOverflowAliasDict[name] {
                return nameAliased
            }
            return name
        }
    }
}

private struct _SchemaDatabaseOutput: DatabaseOutput {
    let output: DatabaseOutput
    let schema: String
    
    var description: String {
        self.output.description
    }
    
    func schema(_ schema: String) -> DatabaseOutput {
        self.output.schema(schema)
    }
    
    func contains(_ key: FieldKey) -> Bool {
        self.output.contains(self.key(key))
    }
    
    func decodeNil(_ key: FieldKey) throws -> Bool {
        try self.output.decodeNil(self.key(key))
    }
    
    func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T
    where T: Decodable
    {
        try self.output.decode(self.key(key), as: T.self)
    }
    
    private func key(_ key: FieldKey) -> FieldKey {
        .prefix(.string(self.schema + "_"), key)
    }
}

