//
//  CreateJeopardyGameView.swift
//  Macopardy
//

import SwiftUI

struct CreateJeopardyGameView: View {
    @Environment(\.dismissWindow) private var dismissWindow

    private static let categoryTitles = [
        "Science",
        "History",
        "Literature",
        "Geography",
        "Pop Culture",
        "Think Music"
    ]

    private static let values = [200, 400, 600, 800, 1000]

    @State
    private var title: String = ""

    @State
    private var draftCategories: [DraftCategory] = Self.makeDefaultCategories()

    @State
    private var selectedQuestion: EditingQuestion?

    @State
    private var validationMessage: String = ""

    @State
    private var showValidationAlert = false

    @State
    private var saveErrorMessage: String = ""

    @State
    private var showSaveErrorAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Game Title")
                    .font(.headline)
                    .foregroundStyle(.primary)

                TextField("My Jeopardy Game", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 420)
                    .accessibilityLabel("Game title")
            }

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(Array(draftCategories.enumerated()), id: \.element.id) { _, category in
                            CategoryHeaderView(title: category.title)
                                .frame(width: 180, height: 80)
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityLabel(category.title)
                        }
                    }

                    ForEach(Array(Self.values.enumerated()), id: \.offset) { rowIndex, value in
                        HStack(spacing: 8) {
                            ForEach(Array(draftCategories.enumerated()), id: \.element.id) { categoryIndex, category in
                                let question = category.questions[rowIndex]
                                                QuestionTileButtonView(
                                    value: value,
                                    isComplete: question.isComplete,
                                    action: {
                                        selectedQuestion = EditingQuestion(
                                            categoryIndex: categoryIndex,
                                            questionIndex: rowIndex,
                                            value: value,
                                            clue: question.clue,
                                            response: question.response
                                        )
                                    }
                                )
                                .frame(width: 180, height: 120)
                                .accessibilityLabel("\(category.title) question for \(value), \(question.isComplete ? "completed" : "incomplete")")
                            }
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Save Game") {
                    saveGame()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel("Save game")
            }
        }
        .padding(20)
        .frame(minWidth: 1200, minHeight: 820)
        .background(JeopardyTheme.controlBackground)
        .alert("Game incomplete", isPresented: $showValidationAlert) {
            Button("OK") {}
        } message: {
            Text(validationMessage)
        }
        .alert("Save failed", isPresented: $showSaveErrorAlert) {
            Button("OK") {}
        } message: {
            Text(saveErrorMessage)
        }
        .sheet(item: $selectedQuestion) { question in
            QuestionEditorView(
                value: question.value,
                clue: Binding(
                    get: { draftCategories[question.categoryIndex].questions[question.questionIndex].clue },
                    set: { newValue in
                        updateQuestion(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            clue: newValue
                        )
                    }
                ),
                response: Binding(
                    get: { draftCategories[question.categoryIndex].questions[question.questionIndex].response },
                    set: { newValue in
                        updateQuestion(
                            categoryIndex: question.categoryIndex,
                            questionIndex: question.questionIndex,
                            response: newValue
                        )
                    }
                ),
                onDone: {
                    selectedQuestion = nil
                }
            )
            .frame(minWidth: 540, minHeight: 360)
        }
    }

    private func updateQuestion(categoryIndex: Int, questionIndex: Int, clue: String? = nil, response: String? = nil) {
        guard categoryIndex >= 0, categoryIndex < draftCategories.count else { return }
        guard questionIndex >= 0, questionIndex < draftCategories[categoryIndex].questions.count else { return }

        draftCategories[categoryIndex].questions[questionIndex].clue = clue ?? draftCategories[categoryIndex].questions[questionIndex].clue
        draftCategories[categoryIndex].questions[questionIndex].response = response ?? draftCategories[categoryIndex].questions[questionIndex].response
    }

    private func saveGame() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            validationMessage = "Your game is incomplete. Please enter a game title before saving."
            showValidationAlert = true
            return
        }
//        let incompleteQuestions = missingQuestions()
//        if !incompleteQuestions.isEmpty {
//            validationMessage = "Your game is incomplete. Please complete all categories and questions before saving. Missing: \(incompleteQuestions.joined(separator: ", "))"
//            showValidationAlert = true
//            return
//        }

        let board = JeopardyBoard(
            title: trimmedTitle,
            round: .jeopardy,
            categories: draftCategories.map { category in
                Category(
                    title: category.title,
                    questions: category.questions.map { question in
                        Question(
                            value: question.value,
                            clue: question.clue.trimmingCharacters(in: .whitespacesAndNewlines),
                            response: question.response.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                )
            }
        )

        do {
            try FileManagerService().saveBoardToStorage(
                title: trimmedTitle,
                board: board,
                onError: { error in
                    saveErrorMessage = error
                    showSaveErrorAlert = true
                }
            )
            dismissWindow(id: "create-jeopardy")
        } catch {
            saveErrorMessage = "The game could not be encoded to JSON. Please try again.\n\(error.localizedDescription)"
            showSaveErrorAlert = true
        }
    }

    private func missingQuestions() -> [String] {
        var missing: [String] = []

        for category in draftCategories {
            for question in category.questions {
                let clueIsEmpty = question.clue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let responseIsEmpty = question.response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                if clueIsEmpty || responseIsEmpty {
                    missing.append("\(category.title) - \(question.value)")
                }
            }
        }

        return missing
    }
    

    private static func makeDefaultCategories() -> [DraftCategory] {
        categoryTitles.map { title in
            DraftCategory(
                title: title,
                questions: values.map { value in
                    DraftQuestion(value: value, clue: "", response: "")
                }
            )
        }
    }
}

private struct QuestionTileButtonView: View {

    let value: Int
    let isComplete: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(JeopardyTheme.tileBlue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isComplete ? JeopardyTheme.gold : Color.clear, lineWidth: 2)
                    )

                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(JeopardyTheme.gold)
                        .padding(8)
                }

                QuestionValueView(value: value)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isComplete ? [.isButton, .isSelected] : [.isButton])
        .accessibilityHint(isComplete ? "Completed question, edit to update" : "Incomplete question, edit to complete")
    }
}

private struct QuestionEditorView: View {

    let value: Int

    @Binding
    var clue: String

    @Binding
    var response: String

    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("$\(value)")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Done") {
                    onDone()
                }
                .buttonStyle(.borderedProminent)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Question / Clue")
                    .font(.headline)

                MultilineTextEditor(text: $clue, placeholder: "Enter the clue or question...")
                    .frame(minHeight: 120)
                    .accessibilityLabel("Question clue for \(value)")
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Answer / Response")
                    .font(.headline)

                MultilineTextEditor(text: $response, placeholder: "Enter the answer or response...")
                    .frame(minHeight: 120)
                    .accessibilityLabel("Answer response for \(value)")
            }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 360)
    }
}

private struct MultilineTextEditor: View {

    @Binding
    var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 8)
                    .padding(.top, 10)
            }

            TextEditor(text: $text)
                .padding(4)
                .background(Color(.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(minHeight: 120)
                .opacity(text.isEmpty ? 0.8 : 1)
        }
    }
}

private struct DraftCategory: Identifiable {

    let id = UUID()
    let title: String
    var questions: [DraftQuestion]
}

private struct DraftQuestion {

    let value: Int
    var clue: String
    var response: String

    var isComplete: Bool {
        !clue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct EditingQuestion: Identifiable {

    let id = UUID()
    let categoryIndex: Int
    let questionIndex: Int
    let value: Int
    let clue: String
    let response: String
}

#Preview {
    CreateJeopardyGameView()
}
