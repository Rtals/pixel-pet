enum CharacterState: CaseIterable, Equatable {
    case idle
    case thinking
    case working
    case waitingApproval
    case success
    case error
    case disconnected
}
