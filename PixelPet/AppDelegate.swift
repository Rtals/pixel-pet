import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petController: PetWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        let controller = PetWindowController()
        petController = controller
        controller.showPet()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
