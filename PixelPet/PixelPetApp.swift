//
//  PixelPetApp.swift
//  PixelPet
//
//  Created by 성민 on 7/28/26.
//

import SwiftUI

@main
struct PixelPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
