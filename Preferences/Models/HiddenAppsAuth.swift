import LocalAuthentication

enum HiddenAppsAuth {
    /// Returns true when Face ID / Touch ID / device passcode succeeded.
    /// Returns nil when biometrics are unavailable (caller shows the mock passcode sheet).
    ///
    /// The system sheet shows only "Touch ID" / "Face ID" plus Cancel, like
    /// Settings does: the reason is a single space (LocalAuthentication rejects
    /// an empty string) and the passcode fallback button is hidden.
    static func authenticate(reason: String = " ") async -> Bool? {
        let ctx = LAContext()
        ctx.localizedFallbackTitle = ""
        var err: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) else { return nil }
        do {
            return try await ctx.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
        } catch {
            return false
        }
    }
}
