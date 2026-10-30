//
//  ResponseTimerTests.swift
//  MacpardyTests
//
//  The buzz-in response timer (issue #59): a phone buzz pauses the question
//  timer and starts the answering team's time; the host's correct / wrong
//  ends it, and wrong resumes the question timer.
//

import XCTest
@testable import Macpardy

@MainActor
final class ResponseTimerTests: XCTestCase {

    private let red = Team(name: "Red", score: 0)
    private let blue = Team(name: "Blue", score: 0)

    /// States made by a test, so their run-loop timers are stopped afterwards.
    private var states: [GameState] = []

    /// Settings with nothing changed, so the host's own timer settings don't reach the tests.
    private let defaults: UserDefaults = {
        let suite = "ResponseTimerTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }()

    override func tearDown() {
        for state in states {
            state.cancelResponse()
            state.timer.stop()
        }
        states = []
        super.tearDown()
    }

    /// A game showing a normal (non–Daily Double) clue with the question timer running.
    private func makeStateOnClue() throws -> GameState {
        let state = GameState(rounds: [MacpardyBoard.sample], teams: [red, blue], phase: .board)
        state.settings = defaults
        let (question, category) = try XCTUnwrap(
            MacpardyBoard.sample.categories.lazy
                .compactMap { category in
                    category.questions.first { !$0.isDailyDouble }.map { ($0, category.title) }
                }
                .first
        )
        state.selectQuestion(question, categoryTitle: category)
        state.timer.start()
        states.append(state)
        return state
    }

    // MARK: - Buzzing in

    func testBuzzPausesQuestionTimerAndStartsResponse() throws {
        let state = try makeStateOnClue()

        state.teamBuzzedIn(red.id)

        XCTAssertFalse(state.timer.isRunning)
        XCTAssertTrue(state.responseTimer.isRunning)
        XCTAssertEqual(state.responseTimer.remainingTime, state.responseSeconds)
        XCTAssertEqual(state.answeringTeamID, red.id)
        XCTAssertEqual(state.responseCountdown?.teamID, red.id)
        XCTAssertEqual(state.responseCountdown?.secondsLeft, 5)
        XCTAssertEqual(state.responseCountdown?.totalSeconds, 5)
    }

    func testRepeatedReportOfSameTeamDoesNotRestartResponse() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)
        state.responseTimer.addSeconds(-2)

        state.teamBuzzedIn(red.id)

        XCTAssertEqual(state.responseTimer.remainingTime, state.responseSeconds - 2, accuracy: 0.001)
    }

    func testBuzzIsIgnoredOnDailyDouble() throws {
        let state = try makeStateOnClue()
        state.submitDailyDoubleWager(teamID: red.id, wager: 500)

        state.teamBuzzedIn(blue.id)

        XCTAssertNil(state.answeringTeamID)
        XCTAssertFalse(state.responseTimer.isRunning)
    }

    func testBuzzIsIgnoredOutsideTheQuestionPhase() throws {
        let state = try makeStateOnClue()
        state.revealAnswer()

        state.teamBuzzedIn(red.id)

        XCTAssertNil(state.answeringTeamID)
        XCTAssertFalse(state.responseTimer.isRunning)
    }

    // MARK: - Judging

    func testWrongResumesQuestionTimerWhereItPaused() throws {
        let state = try makeStateOnClue()
        state.timer.addSeconds(-3)
        let remainingAtBuzz = state.timer.remainingTime
        state.teamBuzzedIn(red.id)

        // Judged before the response time runs out.
        state.judgeResponse(teamID: red.id, isCorrect: false)

        XCTAssertTrue(state.timer.isRunning)
        XCTAssertEqual(state.timer.remainingTime, remainingAtBuzz, accuracy: 0.001)
        XCTAssertNil(state.answeringTeamID)
        XCTAssertNil(state.responseCountdown)
        XCTAssertFalse(state.responseTimer.isRunning)
    }

    func testCorrectLeavesQuestionTimerStopped() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)

        state.judgeResponse(teamID: red.id, isCorrect: true)

        XCTAssertFalse(state.timer.isRunning)
        XCTAssertNil(state.answeringTeamID)
        XCTAssertFalse(state.responseTimer.isRunning)
    }

    func testWrongAfterQuestionTimeRanOutDoesNotRestartIt() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)
        state.timer.addSeconds(-60)

        state.judgeResponse(teamID: red.id, isCorrect: false)

        XCTAssertFalse(state.timer.isRunning)
        XCTAssertEqual(state.timer.remainingTime, 0)
    }

    func testJudgingAnotherTeamLeavesResponseRunning() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)

        state.judgeResponse(teamID: blue.id, isCorrect: false)

        XCTAssertEqual(state.answeringTeamID, red.id)
        XCTAssertTrue(state.responseTimer.isRunning)
        XCTAssertFalse(state.timer.isRunning)
    }

    func testNextTeamGetsAFreshResponseAfterWrong() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)
        state.responseTimer.addSeconds(-3)
        state.judgeResponse(teamID: red.id, isCorrect: false)

        state.teamBuzzedIn(blue.id)

        XCTAssertEqual(state.answeringTeamID, blue.id)
        XCTAssertEqual(state.responseTimer.remainingTime, state.responseSeconds)
        XCTAssertFalse(state.timer.isRunning)
    }

    // MARK: - Cancelling

    func testBuzzersStoppingWithoutJudgementCancelsWithoutResuming() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)

        state.teamBuzzedIn(nil)

        XCTAssertNil(state.answeringTeamID)
        XCTAssertFalse(state.responseTimer.isRunning)
        XCTAssertFalse(state.timer.isRunning)
    }

    func testRevealAnswerAndReturnToBoardCancelResponse() throws {
        let state = try makeStateOnClue()
        state.teamBuzzedIn(red.id)
        state.revealAnswer()
        XCTAssertNil(state.answeringTeamID)
        XCTAssertFalse(state.responseTimer.isRunning)

        let other = try makeStateOnClue()
        other.teamBuzzedIn(blue.id)
        other.showBoard()
        XCTAssertNil(other.answeringTeamID)
        XCTAssertFalse(other.responseTimer.isRunning)
    }

    // MARK: - ResponseCountdown

    func testCountdownRoundsUpToWholeSeconds() {
        let id = UUID()
        XCTAssertEqual(ResponseCountdown(teamID: id, remainingTime: 5, totalTime: 5).secondsLeft, 5)
        XCTAssertEqual(ResponseCountdown(teamID: id, remainingTime: 4.9, totalTime: 5).secondsLeft, 5)
        XCTAssertEqual(ResponseCountdown(teamID: id, remainingTime: 0.1, totalTime: 5).secondsLeft, 1)
        XCTAssertEqual(ResponseCountdown(teamID: id, remainingTime: 0, totalTime: 5).secondsLeft, 0)
        XCTAssertEqual(ResponseCountdown(teamID: id, remainingTime: -0.1, totalTime: 5).secondsLeft, 0)
        XCTAssertTrue(ResponseCountdown(teamID: id, remainingTime: 0, totalTime: 5).isExpired)
    }

    func testCountdownIgnoresFloatDriftFromTenthSteps() {
        // 5 - 0.1 × 10 in floating point is slightly above 4.
        var remaining: TimeInterval = 5
        for _ in 0..<10 { remaining -= 0.1 }
        let countdown = ResponseCountdown(teamID: UUID(), remainingTime: remaining, totalTime: 5)
        XCTAssertEqual(countdown.secondsLeft, 4)
    }
}
