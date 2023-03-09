public protocol EventDataManipulatorPipeline {
    func clearEventDataManipulators()
    func registerEventDataManipulator(manipulator: EventDataManipulator)
}
