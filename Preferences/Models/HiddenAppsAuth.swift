import LocalAuthentication

enum HiddenAppsAuth {
    /// Returns true when Face ID / Touch ID / device passcode succeeded.
    /// Returns nil when biometrics are unavailable (caller shows the mock passcode sheet).
    static func authenticate(reason: String = "Unlock Hidden Apps") async -> Bool? {
        let ctx = LAContext()
        ctx.localizedFallbackTitle = "Enter Passcode"
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) else { return nil }
        do {
            return try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            return false
        }
    }
}
