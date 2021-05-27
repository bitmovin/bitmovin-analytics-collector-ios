internal class CustomDataHelpers {
    protocol CustomDataConfig {
        func get() -> CustomData
        func set(customData: CustomData)
    }
}
