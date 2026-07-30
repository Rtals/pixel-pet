//
//  ContentView.swift
//  PixelPet
//
//  Created by 성민 on 7/28/26.
//

import SwiftUI

struct PetView: View {
    @ObservedObject var model: PetModel
    @ObservedObject var animationController: AnimationController
    let onDrag: (CGSize) -> Void
    let onDragEnded: () -> Void
    let onPreviewState: (CharacterState) -> Void
    let onResumeAutomaticState: () -> Void

    var body: some View {
        PixelPetSprite(
            characterState: model.characterState,
            frame: animationController.frame
        )
            .scaleEffect(x: model.isFacingRight ? 1 : -1, y: 1)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { onDrag($0.translation) }
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

                    Divider()

                    Button("자동 상태로 돌아가기") {
                        onResumeAutomaticState()
                    }
                }

                Divider()

                Button("PixelPet 종료") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .accessibilityLabel("PixelPet")
            .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        if model.isPaused {
            return "멈춤"
        }

        switch model.characterState {
        case .idle:
            return "쉬는 중"
        case .walking:
            return "이동 중"
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

private struct PixelPetSprite: View {
    let characterState: CharacterState
    let frame: Int

    private let pixelSize: CGFloat = 6
    private var isWalking: Bool { characterState == .walking }

    private var pixels: [Pixel] {
        var result: [Pixel] = [
            // Ears
            Pixel(x: 4, y: 2, color: .petOutline),
            Pixel(x: 5, y: 2, color: .petOutline),
            Pixel(x: 10, y: 2, color: .petOutline),
            Pixel(x: 11, y: 2, color: .petOutline),
            Pixel(x: 3, y: 3, color: .petOutline),
            Pixel(x: 4, y: 3, color: .petFur),
            Pixel(x: 5, y: 3, color: .petFur),
            Pixel(x: 6, y: 3, color: .petOutline),
            Pixel(x: 9, y: 3, color: .petOutline),
            Pixel(x: 10, y: 3, color: .petFur),
            Pixel(x: 11, y: 3, color: .petFur),
            Pixel(x: 12, y: 3, color: .petOutline),

            // Head
            Pixel(x: 3, y: 4, color: .petOutline),
            Pixel(x: 4, y: 4, color: .petFur),
            Pixel(x: 5, y: 4, color: .petFur),
            Pixel(x: 6, y: 4, color: .petFur),
            Pixel(x: 7, y: 4, color: .petFur),
            Pixel(x: 8, y: 4, color: .petFur),
            Pixel(x: 9, y: 4, color: .petFur),
            Pixel(x: 10, y: 4, color: .petFur),
            Pixel(x: 11, y: 4, color: .petFur),
            Pixel(x: 12, y: 4, color: .petOutline),
            Pixel(x: 2, y: 5, color: .petOutline),
            Pixel(x: 3, y: 5, color: .petFur),
            Pixel(x: 4, y: 5, color: .petFur),
            Pixel(x: 5, y: 5, color: .petEye),
            Pixel(x: 6, y: 5, color: .petFur),
            Pixel(x: 7, y: 5, color: .petFur),
            Pixel(x: 8, y: 5, color: .petFur),
            Pixel(x: 9, y: 5, color: .petFur),
            Pixel(x: 10, y: 5, color: .petEye),
            Pixel(x: 11, y: 5, color: .petFur),
            Pixel(x: 12, y: 5, color: .petFur),
            Pixel(x: 13, y: 5, color: .petOutline),
            Pixel(x: 2, y: 6, color: .petOutline),
            Pixel(x: 3, y: 6, color: .petFur),
            Pixel(x: 4, y: 6, color: .petFur),
            Pixel(x: 5, y: 6, color: .petFur),
            Pixel(x: 6, y: 6, color: .petFur),
            Pixel(x: 7, y: 6, color: .petNose),
            Pixel(x: 8, y: 6, color: .petNose),
            Pixel(x: 9, y: 6, color: .petFur),
            Pixel(x: 10, y: 6, color: .petFur),
            Pixel(x: 11, y: 6, color: .petFur),
            Pixel(x: 12, y: 6, color: .petFur),
            Pixel(x: 13, y: 6, color: .petOutline),

            // Body
            Pixel(x: 3, y: 7, color: .petOutline),
            Pixel(x: 4, y: 7, color: .petFur),
            Pixel(x: 5, y: 7, color: .petFur),
            Pixel(x: 6, y: 7, color: .petFur),
            Pixel(x: 7, y: 7, color: .petFur),
            Pixel(x: 8, y: 7, color: .petFur),
            Pixel(x: 9, y: 7, color: .petFur),
            Pixel(x: 10, y: 7, color: .petFur),
            Pixel(x: 11, y: 7, color: .petFur),
            Pixel(x: 12, y: 7, color: .petOutline),
            Pixel(x: 4, y: 8, color: .petOutline),
            Pixel(x: 5, y: 8, color: .petFur),
            Pixel(x: 6, y: 8, color: .petFur),
            Pixel(x: 7, y: 8, color: .petBelly),
            Pixel(x: 8, y: 8, color: .petBelly),
            Pixel(x: 9, y: 8, color: .petFur),
            Pixel(x: 10, y: 8, color: .petFur),
            Pixel(x: 11, y: 8, color: .petOutline),
            Pixel(x: 4, y: 9, color: .petOutline),
            Pixel(x: 5, y: 9, color: .petFur),
            Pixel(x: 6, y: 9, color: .petFur),
            Pixel(x: 7, y: 9, color: .petBelly),
            Pixel(x: 8, y: 9, color: .petBelly),
            Pixel(x: 9, y: 9, color: .petFur),
            Pixel(x: 10, y: 9, color: .petFur),
            Pixel(x: 11, y: 9, color: .petOutline)
        ]

        let leftFootX = isWalking && frame == 0 ? 4 : 5
        let rightFootX = isWalking && frame == 0 ? 11 : 10
        result.append(contentsOf: [
            Pixel(x: leftFootX, y: 10, color: .petOutline),
            Pixel(x: leftFootX + 1, y: 10, color: .petOutline),
            Pixel(x: rightFootX - 1, y: 10, color: .petOutline),
            Pixel(x: rightFootX, y: 10, color: .petOutline)
        ])
        result.append(contentsOf: statePixels)

        return result
    }

    private var statePixels: [Pixel] {
        switch characterState {
        case .idle, .walking:
            return []
        case .thinking:
            let dots = [
                Pixel(x: 12, y: 2, color: .petBubble),
                Pixel(x: 13, y: 1, color: .petBubble),
                Pixel(x: 14, y: 0, color: .petBubble)
            ]
            return Array(dots.prefix(frame + 1))
        case .working:
            var laptop = [
                Pixel(x: 5, y: 8, color: .petDevice),
                Pixel(x: 6, y: 8, color: .petScreen),
                Pixel(x: 7, y: 8, color: .petScreen),
                Pixel(x: 8, y: 8, color: .petScreen),
                Pixel(x: 9, y: 8, color: .petScreen),
                Pixel(x: 10, y: 8, color: .petDevice),
                Pixel(x: 5, y: 9, color: .petDevice),
                Pixel(x: 6, y: 9, color: .petScreen),
                Pixel(x: 7, y: 9, color: .petScreen),
                Pixel(x: 8, y: 9, color: .petScreen),
                Pixel(x: 9, y: 9, color: .petScreen),
                Pixel(x: 10, y: 9, color: .petDevice),
                Pixel(x: 4, y: 10, color: .petDevice),
                Pixel(x: 5, y: 10, color: .petDevice),
                Pixel(x: 6, y: 10, color: .petDevice),
                Pixel(x: 7, y: 10, color: .petDevice),
                Pixel(x: 8, y: 10, color: .petDevice),
                Pixel(x: 9, y: 10, color: .petDevice),
                Pixel(x: 10, y: 10, color: .petDevice),
                Pixel(x: 11, y: 10, color: .petDevice)
            ]
            let typingX = frame == 0 ? 5 : 10
            laptop.append(Pixel(x: typingX, y: 9, color: .petPaw))
            return laptop
        case .waitingApproval:
            return [
                Pixel(x: 13, y: frame == 0 ? 0 : 1, color: .petWarning),
                Pixel(x: 13, y: frame == 0 ? 1 : 2, color: .petWarning),
                Pixel(x: 13, y: frame == 0 ? 3 : 4, color: .petWarning)
            ]
        case .success:
            let spread = min(frame, 2)
            return [
                Pixel(x: 2 - spread, y: 2, color: .petSuccess),
                Pixel(x: 13 + spread, y: 2, color: .petSuccess),
                Pixel(x: 3, y: max(0, 1 - spread), color: .petSuccess),
                Pixel(x: 12, y: max(0, 1 - spread), color: .petSuccess)
            ]
        case .error:
            let shift = frame == 0 ? 0 : 1
            return [
                Pixel(x: 12 + shift, y: 0, color: .petError),
                Pixel(x: 14 + shift, y: 0, color: .petError),
                Pixel(x: 13 + shift, y: 1, color: .petError),
                Pixel(x: 12 + shift, y: 2, color: .petError),
                Pixel(x: 14 + shift, y: 2, color: .petError)
            ]
        case .disconnected:
            return [
                Pixel(x: 1, y: 1, color: .petDisconnected),
                Pixel(x: 2, y: 1, color: .petDisconnected),
                Pixel(x: 3, y: 2, color: .petDisconnected),
                Pixel(x: 5, y: 4, color: .petDisconnected),
                Pixel(x: 12, y: 1, color: .petDisconnected),
                Pixel(x: 13, y: 1, color: .petDisconnected),
                Pixel(x: 11, y: 2, color: .petDisconnected),
                Pixel(x: 9, y: 4, color: .petDisconnected)
            ]
        }
    }

    private var verticalOffset: CGFloat {
        switch characterState {
        case .idle:
            return frame == 0 ? 0 : 1
        case .walking, .working:
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

    var body: some View {
        Canvas { context, _ in
            for pixel in pixels {
                let rect = CGRect(
                    x: CGFloat(pixel.x) * pixelSize,
                    y: CGFloat(pixel.y) * pixelSize,
                    width: pixelSize,
                    height: pixelSize
                )
                context.fill(Path(rect), with: .color(pixel.color))
            }
        }
        .frame(width: 96, height: 96)
        .scaleEffect(x: 1, y: verticalScale, anchor: .bottom)
        .rotationEffect(rotation, anchor: .bottom)
        .saturation(characterState == .disconnected ? 0.1 : 1)
        .opacity(characterState == .disconnected && frame == 0 ? 0.48 : 1)
        .offset(y: verticalOffset)
    }
}

private struct Pixel {
    let x: Int
    let y: Int
    let color: Color
}

private extension Color {
    static let petOutline = Color(red: 0.12, green: 0.10, blue: 0.18)
    static let petFur = Color(red: 0.43, green: 0.79, blue: 0.93)
    static let petBelly = Color(red: 0.75, green: 0.94, blue: 0.98)
    static let petEye = Color.white
    static let petNose = Color(red: 0.96, green: 0.47, blue: 0.58)
    static let petBubble = Color.white
    static let petDevice = Color(red: 0.20, green: 0.25, blue: 0.36)
    static let petScreen = Color(red: 0.38, green: 0.93, blue: 0.76)
    static let petPaw = Color(red: 0.75, green: 0.94, blue: 0.98)
    static let petWarning = Color(red: 1.00, green: 0.76, blue: 0.20)
    static let petSuccess = Color(red: 0.46, green: 0.94, blue: 0.48)
    static let petError = Color(red: 1.00, green: 0.30, blue: 0.36)
    static let petDisconnected = Color(red: 0.58, green: 0.62, blue: 0.70)
}

private extension CharacterState {
    var menuTitle: String {
        switch self {
        case .idle:
            return "대기"
        case .walking:
            return "걷기"
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
