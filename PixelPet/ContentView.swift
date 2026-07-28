//
//  ContentView.swift
//  PixelPet
//
//  Created by 성민 on 7/28/26.
//

import SwiftUI

struct PetView: View {
    @ObservedObject var model: PetModel
    let onDrag: (CGSize) -> Void
    let onDragEnded: () -> Void

    var body: some View {
        PixelPetSprite(isWalking: model.isWalking, frame: model.animationFrame)
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

                Divider()

                Button("PixelPet 종료") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .accessibilityLabel("PixelPet")
            .accessibilityValue(model.isPaused ? "멈춤" : "이동 중")
    }
}

private struct PixelPetSprite: View {
    let isWalking: Bool
    let frame: Int

    private let pixelSize: CGFloat = 6

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

        return result
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
        .offset(y: isWalking && frame == 1 ? -2 : 0)
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
}
