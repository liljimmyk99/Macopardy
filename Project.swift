import ProjectDescription

let project = Project(
    name: "Macopardy",
    packages: [
        .remote(
            url: "https://github.com/weichsel/ZIPFoundation",
            requirement: .upToNextMinor(from: "0.9.19")
        ),
    ],
    targets: [
        .target(
            name: "Macopardy",
            destinations: [.mac],
            product: .app,
            bundleId: "jbkiv.Macopardy",
            deploymentTargets: .macOS("26.3"),
            infoPlist: .extendingDefault(with: [
                // Board packages (.macpardy): a zip with board.json and images/.
                "UTExportedTypeDeclarations": [
                    [
                        "UTTypeIdentifier": "jbkiv.macopardy.board",
                        "UTTypeDescription": "Macopardy Board",
                        "UTTypeConformsTo": ["public.data", "public.archive"],
                        "UTTypeTagSpecification": [
                            "public.filename-extension": ["macpardy"],
                        ],
                    ],
                ],
                "CFBundleDocumentTypes": [
                    [
                        "CFBundleTypeName": "Macopardy Board",
                        "CFBundleTypeRole": "Editor",
                        "LSHandlerRank": "Owner",
                        "LSItemContentTypes": ["jbkiv.macopardy.board"],
                    ],
                ],
            ]),
            sources: ["Macopardy/**/*.swift"],
            resources: [
                "Macopardy/Assets.xcassets",
                "Macopardy/Localizable.xcstrings",
                "Macopardy/Resources/Buzzer/**",
            ],
            dependencies: [
                .package(product: "ZIPFoundation"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "CODE_SIGN_STYLE": "Automatic",
                    "CODE_SIGN_ENTITLEMENTS": "Config/Macopardy.entitlements",
                    "COMBINE_HIDPI_IMAGES": "YES",
                    "CURRENT_PROJECT_VERSION": "1",
                    "ENABLE_APP_SANDBOX": "YES",
                    "ENABLE_INCOMING_NETWORK_CONNECTIONS": "YES",
                    "ENABLE_OUTGOING_NETWORK_CONNECTIONS": "NO",
                    "ENABLE_PREVIEWS": "YES",
                    "ENABLE_RESOURCE_ACCESS_AUDIO_INPUT": "NO",
                    "ENABLE_RESOURCE_ACCESS_BLUETOOTH": "NO",
                    "ENABLE_RESOURCE_ACCESS_CALENDARS": "NO",
                    "ENABLE_RESOURCE_ACCESS_CAMERA": "NO",
                    "ENABLE_RESOURCE_ACCESS_CONTACTS": "NO",
                    "ENABLE_RESOURCE_ACCESS_LOCATION": "NO",
                    "ENABLE_RESOURCE_ACCESS_PRINTING": "NO",
                    "ENABLE_RESOURCE_ACCESS_USB": "NO",
                    "ENABLE_USER_SELECTED_FILES": "readwrite",
                    "GENERATE_INFOPLIST_FILE": "YES",
                    "INFOPLIST_KEY_LSApplicationCategoryType": "public.app-category.games",
                    "INFOPLIST_KEY_NSHumanReadableCopyright": "",
                    "LD_RUNPATH_SEARCH_PATHS": [
                        "$(inherited)",
                        "@executable_path/../Frameworks",
                    ],
                    "MACOSX_DEPLOYMENT_TARGET": "26.3",
                    "MARKETING_VERSION": "0.2.0",
                    "PRODUCT_BUNDLE_IDENTIFIER": "jbkiv.Macopardy",
                    "REGISTER_APP_GROUPS": "YES",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
                    "SWIFT_VERSION": "5.0",
                ],
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "DEBUG": "1",
                            "ENABLE_TESTABILITY": "YES",
                            "GCC_OPTIMIZATION_LEVEL": "0",
                            "ONLY_ACTIVE_ARCH": "YES",
                            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG $(inherited)",
                            "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
                        ]
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "CODE_SIGN_INJECT_BASE_ENTITLEMENTS": "NO",
                            "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                            "ENABLE_HARDENED_RUNTIME": "YES",
                            "ENABLE_NS_ASSERTIONS": "NO",
                            "SWIFT_COMPILATION_MODE": "wholemodule",
                        ]
                    ),
                ],
                defaultSettings: .recommended
            )
        ),
        .target(
            name: "MacopardyTests",
            destinations: [.mac],
            product: .unitTests,
            bundleId: "jbkiv.MacopardyTests",
            deploymentTargets: .macOS("26.3"),
            infoPlist: .default,
            sources: ["MacopardyTests/**/*.swift"],
            dependencies: [.target(name: "Macopardy")],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.0",
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "GENERATE_INFOPLIST_FILE": "YES",
                ]
            )
        ),
    ]
)
