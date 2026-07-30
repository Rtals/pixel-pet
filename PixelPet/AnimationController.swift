import Combine
import Foundation

@MainActor
final class AnimationController: ObservableObject {
    @Published private(set) var frame = 0

    private var currentState: CharacterState = .idle
    private var elapsedTime: TimeInterval = 0

    func update(for state: CharacterState, deltaTime: TimeInterval) {
        if state != currentState {
            currentState = state
            frame = 0
            elapsedTime = 0
        }

        let animation = AnimationDefinition.animation(for: state)
        elapsedTime += deltaTime

        while elapsedTime >= animation.frameDuration {
            elapsedTime -= animation.frameDuration
            advanceFrame(using: animation)
        }
    }

    private func advanceFrame(using animation: AnimationDefinition) {
        let nextFrame = frame + 1

        if nextFrame < animation.frameCount {
            frame = nextFrame
        } else if animation.repeats {
            frame = 0
        }
    }
}

private struct AnimationDefinition {
    let frameCount: Int
    let frameDuration: TimeInterval
    let repeats: Bool

    static func animation(for state: CharacterState) -> AnimationDefinition {
        switch state {
        case .idle:
            return AnimationDefinition(frameCount: 2, frameDuration: 0.22, repeats: true)
        case .thinking:
            return AnimationDefinition(frameCount: 3, frameDuration: 0.45, repeats: true)
        case .working:
            return AnimationDefinition(frameCount: 2, frameDuration: 0.18, repeats: true)
        case .waitingApproval:
            return AnimationDefinition(frameCount: 2, frameDuration: 0.5, repeats: true)
        case .success:
            return AnimationDefinition(frameCount: 4, frameDuration: 0.14, repeats: false)
        case .error:
            return AnimationDefinition(frameCount: 2, frameDuration: 0.22, repeats: true)
        case .disconnected:
            return AnimationDefinition(frameCount: 2, frameDuration: 0.8, repeats: true)
        }
    }
}
