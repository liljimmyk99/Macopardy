//
//  BoardOpenDialogs.swift
//  Macpardy
//
//  The file picker, Play / Edit choice, confirmations and error sheet for
//  `BoardOpenCoordinator`. Applied at the root of the Control window.
//

import SwiftUI
import UniformTypeIdentifiers

struct BoardOpenDialogs: ViewModifier {

    @Bindable var coordinator: BoardOpenCoordinator

    @Environment(\.openWindow) private var openWindow

    private func isPresented<T>(_ keyPath: ReferenceWritableKeyPath<BoardOpenCoordinator, T?>) -> Binding<Bool> {
        Binding(
            get: { coordinator[keyPath: keyPath] != nil },
            set: { if !$0 { coordinator[keyPath: keyPath] = nil } }
        )
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                coordinator.showEditor = { openWindow(id: "create-macpardy") }
            }
            .fileImporter(
                isPresented: $coordinator.isImporterPresented,
                allowedContentTypes: [.macpardyBoard, .json, .zip, .commaSeparatedText]
            ) { result in
                coordinator.handleImport(result)
            }
            .confirmationDialog(
                "board_open.choice.title",
                isPresented: isPresented(\.pendingBoard),
                presenting: coordinator.pendingBoard
            ) { pending in
                Button("board_open.choice.play") {
                    Task { await coordinator.play(pending) }
                }
                Button("board_open.choice.edit") {
                    coordinator.edit(pending)
                }
                Button("common.cancel", role: .cancel) {}
            } message: { pending in
                Text("board_open.choice.message \(pending.url.lastPathComponent)")
            }
            .confirmationDialog(
                "board_open.replace.title",
                isPresented: isPresented(\.pendingReplacement),
                presenting: coordinator.pendingReplacement
            ) { pending in
                Button("board_open.replace.confirm", role: .destructive) {
                    coordinator.confirmReplacement(pending)
                }
                Button("common.cancel", role: .cancel) {}
            } message: { _ in
                Text("board_open.replace.message")
            }
            .confirmationDialog(
                "board_open.discard_edits.title",
                isPresented: isPresented(\.pendingEdit),
                presenting: coordinator.pendingEdit
            ) { pending in
                Button("board_open.discard_edits.confirm", role: .destructive) {
                    coordinator.confirmEdit(pending)
                }
                Button("common.cancel", role: .cancel) {}
            } message: { _ in
                Text("board_open.discard_edits.message")
            }
            .sheet(item: $coordinator.loadError) { report in
                BoardLoadErrorView(report: report)
            }
    }
}

extension View {
    func boardOpenDialogs(_ coordinator: BoardOpenCoordinator) -> some View {
        modifier(BoardOpenDialogs(coordinator: coordinator))
    }
}
