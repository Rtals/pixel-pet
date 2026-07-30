import Combine

@MainActor
final class PetModel: ObservableObject {
    @Published private(set) var characterState: CharacterState = .idle
    @Published var isFacingRight = true
    @Published var animationFrame = 0
    @Published var isPaused = false

    func transition(to newState: CharacterState) {
        guard characterState != newState else { return }
        characterState = newState
    }
}
