public protocol EventDataManipulatorPipeline {
    func registerEventDataManipulator(manipulator: EventDataManipulator)
}
