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
                animationController: animationController
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

    var body: some View {
        CatCharacterSprite(
            characterState: characterState,
            frame: animationController.frame
        )
    }
}

private struct CatCharacterSprite: View {
    let characterState: CharacterState
    let frame: Int

    var body: some View {
        Image("CatCharacter")
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .padding(4)
            .frame(width: 112, height: 112)
            .scaleEffect(x: 1, y: verticalScale, anchor: .bottom)
            .rotationEffect(rotation, anchor: .bottom)
            .saturation(characterState == .disconnected ? 0.1 : 1)
            .opacity(characterState == .disconnected && frame == 0 ? 0.48 : 1)
            .offset(y: verticalOffset)
    }

    private var verticalOffset: CGFloat {
        switch characterState {
        case .idle, .working:
            return frame == 0 ? 0 : -2
        case .success:
            return [0, -5, -9, -3][min(frame, 3)]
        default:
            return 0
        }
    }

    private var rotation: Angle {
        switch characterState {
        case .thinking:
            return [.degrees(-3), .zero, .degrees(3)][min(frame, 2)]
        case .error:
            return frame == 0 ? .degrees(-4) : .degrees(4)
        default:
            return .zero
        }
    }

    private var verticalScale: CGFloat {
        characterState == .idle && frame == 1 ? 1.02 : 1
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
