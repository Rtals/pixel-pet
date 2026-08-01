import AppKit
import SwiftUI

@MainActor
final class PetWindowController {
    private enum MotionPhase {
        case resting(until: TimeInterval)
        case walking(targetX: CGFloat)
    }

    private let petSize = CGSize(width: 112, height: 112)
    private let model = PetModel()
    private let animationController = AnimationController()
    private let panel: NSPanel

    private var timer: Timer?
    private var motionPhase: MotionPhase = .resting(until: 0)
    private var lastTick = ProcessInfo.processInfo.systemUptime
    private var dragStartOrigin: CGPoint?
    private var dragStartMouseLocation: CGPoint?
    private var previewState: CharacterState?

    init() {
        panel = NSPanel(
            contentRect: CGRect(origin: .zero, size: petSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        configurePanel()

        let petView = PetView(
            model: model,
            animationController: animationController,
            onDrag: { [weak self] in
                self?.dragPet()
            },
            onDragEnded: { [weak self] in
                self?.finishDragging()
            },
            onPreviewState: { [weak self] state in
                self?.preview(state)
            }
        )
        panel.contentView = NSHostingView(rootView: petView)
    }

    func showPet() {
        guard let screen = NSScreen.main else { return }

        let visibleFrame = screen.visibleFrame
        let initialOrigin = CGPoint(
            x: visibleFrame.midX - petSize.width / 2,
            y: visibleFrame.minY
        )
        panel.setFrameOrigin(initialOrigin)
        panel.orderFrontRegardless()

        chooseNextMotion(at: ProcessInfo.processInfo.systemUptime)
        startTimer()
    }

    private func configurePanel() {
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary
        ]
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = false
        panel.isReleasedWhenClosed = false
    }

    private func startTimer() {
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) {
            [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        let now = ProcessInfo.processInfo.systemUptime
        let deltaTime = min(now - lastTick, 0.05)
        lastTick = now

        if RunLoop.current.currentMode == .eventTracking {
            animationController.update(
                for: model.characterState,
                deltaTime: deltaTime
            )
            return
        }

        if let previewState {
            model.transition(to: previewState)
        } else if model.isPaused || dragStartOrigin != nil {
            model.transition(to: .idle)
        } else {
            switch motionPhase {
            case .resting(let until):
                model.transition(to: .idle)
                if now >= until {
                    chooseNextMotion(at: now)
                }

            case .walking(let targetX):
                walk(toward: targetX, deltaTime: deltaTime, now: now)
            }
        }

        animationController.update(for: model.characterState, deltaTime: deltaTime)
    }

    private func walk(toward targetX: CGFloat, deltaTime: TimeInterval, now: TimeInterval) {
        let origin = panel.frame.origin
        let remainingDistance = targetX - origin.x

        guard abs(remainingDistance) > 1 else {
            panel.setFrameOrigin(CGPoint(x: targetX, y: origin.y))
            motionPhase = .resting(until: now + .random(in: 1.0...3.0))
            model.transition(to: .idle)
            return
        }

        let direction: CGFloat = remainingDistance > 0 ? 1 : -1
        let speed: CGFloat = 48
        let step = min(abs(remainingDistance), speed * deltaTime)
        let isFacingRight = direction > 0
        if model.isFacingRight != isFacingRight {
            model.isFacingRight = isFacingRight
        }
        model.transition(to: .idle)

        let nextOrigin = CGPoint(
            x: origin.x + direction * step,
            y: origin.y
        )
        panel.setFrameOrigin(nextOrigin)
    }

    private func chooseNextMotion(at now: TimeInterval) {
        guard let screen = panel.screen ?? NSScreen.main else { return }

        let visibleFrame = screen.visibleFrame
        let minimumX = visibleFrame.minX
        let maximumX = visibleFrame.maxX - petSize.width
        let targetX = CGFloat.random(in: minimumX...max(minimumX, maximumX))

        if abs(targetX - panel.frame.minX) < 40 {
            motionPhase = .resting(until: now + .random(in: 0.8...2.0))
        } else {
            motionPhase = .walking(targetX: targetX)
        }
    }

    private func dragPet() {
        if dragStartOrigin == nil {
            dragStartOrigin = panel.frame.origin
            dragStartMouseLocation = NSEvent.mouseLocation
        }
        guard
            let startOrigin = dragStartOrigin,
            let startMouseLocation = dragStartMouseLocation
        else {
            return
        }

        let mouseLocation = NSEvent.mouseLocation

        let proposed = CGPoint(
            x: startOrigin.x + mouseLocation.x - startMouseLocation.x,
            y: startOrigin.y + mouseLocation.y - startMouseLocation.y
        )
        panel.setFrameOrigin(clampedOrigin(proposed))
    }

    private func finishDragging() {
        dragStartOrigin = nil
        dragStartMouseLocation = nil
        motionPhase = .resting(
            until: ProcessInfo.processInfo.systemUptime + 0.8
        )
    }

    private func preview(_ state: CharacterState) {
        guard state != .idle else {
            resumeAutomaticState()
            return
        }

        previewState = state
        model.transition(to: state)
    }

    private func resumeAutomaticState() {
        previewState = nil
        model.isPaused = false
        motionPhase = .resting(
            until: ProcessInfo.processInfo.systemUptime + 0.5
        )
        model.transition(to: .idle)
    }

    private func clampedOrigin(_ origin: CGPoint) -> CGPoint {
        guard let screen = screen(containing: origin) ?? panel.screen ?? NSScreen.main else {
            return origin
        }

        let frame = screen.visibleFrame
        return CGPoint(
            x: min(max(origin.x, frame.minX), frame.maxX - petSize.width),
            y: min(max(origin.y, frame.minY), frame.maxY - petSize.height)
        )
    }

    private func screen(containing origin: CGPoint) -> NSScreen? {
        let center = CGPoint(
            x: origin.x + petSize.width / 2,
            y: origin.y + petSize.height / 2
        )
        return NSScreen.screens.first { $0.frame.contains(center) }
    }
}
