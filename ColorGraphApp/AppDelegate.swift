import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var mqttService: MQTTService?

    func applicationWillTerminate(_ notification: Notification) {
        //mqttService?.shutdownSynchronously()
    }
}

