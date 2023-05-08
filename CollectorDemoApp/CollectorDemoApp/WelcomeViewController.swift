import Foundation
import UIKit

class WelcomeViewController: UIViewController {
    @IBAction func avPlayerExampleWasPressed(_ sender: UIButton) {
        let viewController = AVFoundationViewController.makeFromStoryboard()
        viewController.url = URL(string: VideoAssets.sintel)

        present(viewController, animated: true)
    }
    
    @IBAction func avPlayerOfflineExampleWasPressed(_ sender: UIButton) {
        let viewController = AVFoundationViewController.makeFromStoryboard()
        viewController.url = VideoAssets.artOfMotionLocal

        present(viewController, animated: true)
    }
}
