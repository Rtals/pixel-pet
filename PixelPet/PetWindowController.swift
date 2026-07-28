import AppKit
import Combine
import SwiftUI

@MainActor
final class PetModel: ObservableObject {
    @Published var isWalking = false
    @Published var isFacingRight = true
    @Published var animationFrame = 0
    @Published var isPaused = false
}

@MainActor
final class PetWindowController {
    private enum MotionPhase {
        case resting(until: TimeInterval)
        case walking(targetX: CGFloat)
    }

    private let petSize = CGSize(width: 96, height: 96)
    private let model = PetModel()
    private let panel: NSPanel

    private var timer: Timer?
    private var motionPhase: MotionPhase = .resting(until: 0)
    private var lastTick = ProcessInfo.processInfo.systemUptime
    private var animationAccumulator: TimeInterval = 0
    private var dragStartOrigin: CGPoint?

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
            onDrag: { [weak self] translation in
                self?.dragPet(by: translation)
            },
            onDragEnded: { [weak self] in
                self?.finishDragging()
            }
        )
        panel.contentView = NSHostingView(rootView: petView)
    }

    func showPet() {
        guard let screen = NSScreen.main else { return }

        let visibleFrame = screen.visibleFrame
        let initialOrigin = CGPoint(
            x: visibleFrame.midX - petSize.width / 2,
            y: visibleFrame.minY + 24
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) {
            [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
    }

    private func tick() {
        let now = ProcessInfo.processInfo.systemUptime
        let deltaTime = min(now - lastTick, 0.05)
        lastTick = now

        guard !model.isPaused, dragStartOrigin == nil else {
            model.isWalking = false
            return
        }

        switch motionPhase {
        case .resting(let until):
            model.isWalking = false
            if now >= until {
                chooseNextMotion(at: now)
            }

        case .walking(let targetX):
            walk(toward: targetX, deltaTime: deltaTime, now: now)
        }
    }

    private func walk(toward targetX: CGFloat, deltaTime: TimeInterval, now: TimeInterval) {
        let origin = panel.frame.origin
        let remainingDistance = targetX - origin.x

        guard abs(remainingDistance) > 1 else {
            panel.setFrameOrigin(CGPoint(x: targetX, y: origin.y))
            motionPhase = .resting(until: now + .random(in: 1.0...3.0))
            model.isWalking = false
            return
        }

        let direction: CGFloat = remainingDistance > 0 ? 1 : -1
        let speed: CGFloat = 48
        let step = min(abs(remainingDistance), speed * deltaTime)
        model.isFacingRight = direction > 0
        model.isWalking = true

        animationAccumulator += deltaTime
        if animationAccumulator >= 0.22 {
            animationAccumulator = 0
            model.animationFrame = model.animationFrame == 0 ? 1 : 0
        }

        let nextOrigin = CGPoint(
            x: origin.x + direction * step,
            y: floorY(for: panel.screen)
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

    private func floorY(for screen: NSScreen?) -> CGFloat {
        (screen ?? NSScreen.main)?.visibleFrame.minY ?? panel.frame.minY
    }

    private func dragPet(by translation: CGSize) {
        if dragStartOrigin == nil {
            dragStartOrigin = panel.frame.origin
        }
        guard let start = dragStartOrigin else { return }

        let proposed = CGPoint(
            x: start.x + translation.width,
            y: start.y - translation.height
        )
        panel.setFrameOrigin(clampedOrigin(proposed))
    }

    private func finishDragging() {
        dragStartOrigin = nil
        motionPhase = .resting(
            until: ProcessInfo.processInfo.systemUptime + 0.8
        )
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
