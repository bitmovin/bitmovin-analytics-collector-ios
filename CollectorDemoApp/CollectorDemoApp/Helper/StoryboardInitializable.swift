import UIKit

protocol StoryboardInitializable {
    static var storyboardName: String { get }
    static var storyboardBundle: Bundle? { get }
    static var storyboardIdentifier: String { get }

    static func makeFromStoryboard() -> Self
}

extension StoryboardInitializable where Self: UIViewController {
    static var storyboardName: String {
        "Main"
    }

    static var storyboardBundle: Bundle? {
        nil
    }

    static var storyboardIdentifier: String {
        String(describing: self)
    }

    static func makeFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}
