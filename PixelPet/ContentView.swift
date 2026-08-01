//
//  ContentView.swift
//  PixelPet
//
//  Created by 성민 on 7/28/26.
//

import SwiftUI

struct PetView: View {
    @ObservedObject var model: PetModel
    let animationController: AnimationController
    let onDrag: () -> Void
    let onDragEnded: () -> Void
    let onPreviewState: (CharacterState) -> Void

    var body: some View {
        ZStack {
            AnimatedCatCharacterSprite(
                characterState: model.characterState,
                animationController: animationController,
                isFacingRight: model.isFacingRight
            )

            interactionLayer
        }
            .scaleEffect(x: model.isFacingRight ? -1 : 1, y: 1)
            .accessibilityLabel("PixelPet")
            .accessibilityValue(accessibilityValue)
    }

    private var interactionLayer: some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onDrag() }
                    .onEnded { _ in onDragEnded() }
            )
            .contextMenu {
                Button(model.isPaused ? "움직이기" : "잠시 멈추기") {
                    model.isPaused.toggle()
                }

                Menu("애니메이션 테스트") {
                    ForEach(CharacterState.allCases, id: \.self) { state in
                        Button(state.menuTitle) {
                            onPreviewState(state)
                        }
                    }
                }

                Divider()

                Button("PixelPet 종료") {
                    NSApplication.shared.terminate(nil)
                }
            }
    }

    private var accessibilityValue: String {
        if model.isPaused {
            return "멈춤"
        }

        switch model.characterState {
        case .idle:
            return "대기 중"
        case .thinking:
            return "생각 중"
        case .working:
            return "작업 중"
        case .waitingApproval:
            return "승인 대기 중"
        case .success:
            return "작업 성공"
        case .error:
            return "오류"
        case .disconnected:
            return "연결 끊김"
        }
    }
}

private struct AnimatedCatCharacterSprite: View {
    let characterState: CharacterState
    @ObservedObject var animationController: AnimationController
    let isFacingRight: Bool

    var body: some View {
        CatCharacterSprite(
            characterState: characterState,
            frame: animationController.frame,
            isFacingRight: isFacingRight
        )
    }
}

private struct CatCharacterSprite: View {
    let characterState: CharacterState
    let frame: Int
    let isFacingRight: Bool

    var body: some View {
        ZStack {
            Image(characterState == .working ? "CatCharacterWorking" : "CatCharacter")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .padding(4)
                .frame(width: 112, height: 112)
                .scaleEffect(x: 1, y: verticalScale, anchor: .bottom)
                .rotationEffect(rotation, anchor: .bottom)
                .saturation(characterState == .disconnected ? 0.1 : 1)
                .opacity(characterOpacity)
                .offset(y: verticalOffset)

            CharacterStateEffect(
                characterState: characterState,
                frame: frame,
                isFacingRight: isFacingRight
            )
        }
        .frame(width: 112, height: 112)
    }

    private var verticalOffset: CGFloat {
        switch characterState {
        case .idle:
            return frame == 0 ? 0 : -2
        case .working:
            return 0
        case .success:
            return [0, -8, -17, -17, -8, 0][frame % 6]
        default:
            return 0
        }
    }

    private var rotation: Angle {
        switch characterState {
        case .thinking:
            return [
                .degrees(-7), .degrees(-3), .degrees(3),
                .degrees(7), .degrees(3), .degrees(-3)
            ][min(frame, 5)]
        case .error:
            return frame == 0 ? .degrees(-4) : .degrees(4)
        default:
            return .zero
        }
    }

    private var verticalScale: CGFloat {
        switch characterState {
        case .idle:
            return frame == 1 ? 1.02 : 1
        case .success:
            return [1, 0.96, 1.04, 1.04, 0.98, 1][frame % 6]
        default:
            return 1
        }
    }

    private var characterOpacity: Double {
        guard characterState == .disconnected else { return 1 }
        return [0.42, 0.72, 0.55][min(frame, 2)]
    }

}

private struct CharacterStateEffect: View {
    let characterState: CharacterState
    let frame: Int
    let isFacingRight: Bool

    var body: some View {
        ZStack {
            switch characterState {
            case .idle:
                EmptyView()
            case .thinking:
                PixelQuestionMark()
                    .scaleEffect(x: isFacingRight ? -1 : 1, y: 1)
                    .offset(
                        x: 31,
                        y: [-31, -35, -37, -35, -31, -29][min(frame, 5)]
                    )
            case .working:
                laptop
                workingSweatDrop
            case .waitingApproval:
                PixelExclamationMark(color: Color(red: 1, green: 0.78, blue: 0.08))
                    .offset(x: 31, y: frame == 0 ? -31 : -35)
            case .success:
                fireworks
            case .error:
                PixelExclamationMark(color: Color(red: 0.95, green: 0.12, blue: 0.12))
                    .scaleEffect(frame == 0 ? 0.9 : 1.08)
                    .offset(x: 31, y: -32)
            case .disconnected:
                disconnectedSignal
            }
        }
        .frame(width: 112, height: 112)
        .allowsHitTesting(false)
    }

    private var laptop: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.32, green: 0.2, blue: 0.13))
                .frame(width: 90, height: 6)
                .offset(x: -4)

            Rectangle()
                .fill(Color(red: 0.12, green: 0.15, blue: 0.19))
                .frame(width: 5, height: 20)
                .offset(x: -34, y: -10)

            Rectangle()
                .fill(Color(red: 0.12, green: 0.15, blue: 0.19))
                .frame(width: 22, height: 4)
                .offset(x: -34, y: -1)

            Rectangle()
                .fill(Color(red: 0.08, green: 0.1, blue: 0.13))
                .frame(width: 42, height: 24)
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.08, green: 0.1, blue: 0.13), lineWidth: 3)
                )
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.16, green: 0.2, blue: 0.25))
                        .frame(width: 5, height: 5)
                )
                .offset(x: -34, y: -32)

            ZStack {
                Rectangle()
                    .fill(Color(red: 0.34, green: 0.4, blue: 0.47))
                    .frame(width: 44, height: 10)

                HStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(red: 0.12, green: 0.15, blue: 0.19))
                            .frame(width: 3, height: 3)
                    }
                }
            }
            .offset(y: -8)

            HStack(spacing: 15) {
                paw(isRaised: frame == 0 || frame == 3)
                    .offset(x: 4)
                paw(isRaised: frame == 1 || frame == 2)
            }
            .offset(y: -15)
        }
        .offset(x: -5, y: 30)
    }

    private func paw(isRaised: Bool) -> some View {
        Rectangle()
            .fill(Color(red: 0.31, green: 0.29, blue: 0.41))
            .frame(width: 9, height: 7)
            .offset(y: isRaised ? -3 : 1)
    }

    private var workingSweatDrop: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 3, height: 3)
            Rectangle()
                .frame(width: 5, height: 4)
            Rectangle()
                .frame(width: 7, height: 5)
            Rectangle()
                .frame(width: 5, height: 3)
        }
        .foregroundStyle(Color(red: 0.2, green: 0.75, blue: 1))
        .offset(x: 20, y: -14)
    }

    private var fireworks: some View {
        ZStack {
            firework(color: .yellow, visibleFrom: 2)
                .offset(x: -34, y: -31)
            firework(color: Color(red: 1, green: 0.32, blue: 0.5), visibleFrom: 3)
                .offset(x: 34, y: -23)
        }
    }

    private func firework(color: Color, visibleFrom: Int) -> some View {
        let successFrame = frame % 6
        let isVisible = successFrame >= visibleFrom && successFrame <= visibleFrom + 2
        return ZStack {
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 9)
                    .offset(y: -12 - CGFloat(successFrame - visibleFrom) * 3)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(0.75 + CGFloat(max(0, successFrame - visibleFrom)) * 0.2)
    }

    private var disconnectedSignal: some View {
        ZStack {
            WiFiSymbol()
                .stroke(
                    Color.gray.opacity(frame == 0 ? 0.62 : 0.9),
                    style: StrokeStyle(lineWidth: 3, lineCap: .square)
                )
                .frame(width: 32, height: 27)

            Circle()
                .fill(Color.gray.opacity(frame == 0 ? 0.62 : 0.9))
                .frame(width: 5, height: 5)
                .offset(y: 10)

            Rectangle()
                .fill(Color.red)
                .frame(width: 4, height: 34)
                .rotationEffect(.degrees(45))
        }
        .offset(x: 31, y: -30)
    }
}

private struct WiFiSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        let centerX = rect.midX
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + 2, y: rect.minY + 9))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 2, y: rect.minY + 9),
            control: CGPoint(x: centerX, y: rect.minY - 3)
        )

        path.move(to: CGPoint(x: rect.minX + 8, y: rect.minY + 16))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - 8, y: rect.minY + 16),
            control: CGPoint(x: centerX, y: rect.minY + 8)
        )

        return path
    }
}

private struct PixelQuestionMark: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: 21, height: 7)
            Rectangle()
                .frame(width: 7, height: 7)
                .frame(width: 21, alignment: .trailing)
            Rectangle()
                .frame(width: 14, height: 7)
                .frame(width: 21, alignment: .trailing)
            Rectangle()
                .frame(width: 7, height: 7)
            Color.clear.frame(width: 7, height: 4)
            Rectangle()
                .frame(width: 7, height: 7)
        }
        .foregroundStyle(Color(red: 1, green: 0.78, blue: 0.08))
    }
}

private struct PixelExclamationMark: View {
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Rectangle().frame(width: 7, height: 20)
            Rectangle().frame(width: 7, height: 7)
        }
        .foregroundStyle(color)
    }
}

private extension CharacterState {
    var menuTitle: String {
        switch self {
        case .idle:
            return "대기"
        case .thinking:
            return "생각"
        case .working:
            return "작업"
        case .waitingApproval:
            return "승인 대기"
        case .success:
            return "성공"
        case .error:
            return "오류"
        case .disconnected:
            return "연결 끊김"
        }
    }
}
