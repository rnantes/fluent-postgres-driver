// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "fluent-postgres-driver",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "FluentPostgresDriver", targets: ["FluentPostgresDriver"]),
    ],
    dependencies: [
        //.package(url: "https://github.com/vapor/fluent-kit.git", from: "1.0.0-rc.1"),
        .package(url: "https://github.com/rnantes/fluent-kit.git", .branch("master")),
        //.package(url: "https://github.com/vapor/postgres-kit.git", from: "2.0.0"),
        .package(url: "https://github.com/rnantes/postgres-kit.git", .branch("all-encoding-strategies")),
    ],
    targets: [
        .target(name: "FluentPostgresDriver", dependencies: [
            .product(name: "FluentKit", package: "fluent-kit"),
            .product(name: "FluentSQL", package: "fluent-kit"),
            .product(name: "PostgresKit", package: "postgres-kit"),
        ]),
        .testTarget(name: "FluentPostgresDriverTests", dependencies: [
            .product(name: "FluentBenchmark", package: "fluent-kit"),
            .target(name: "FluentPostgresDriver"),
        ]),
    ]
)
