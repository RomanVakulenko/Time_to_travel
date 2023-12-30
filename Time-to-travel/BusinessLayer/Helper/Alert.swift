//
//  Alert.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 03.10.2023.
//

import Foundation
import UIKit

enum Alert {
    static func showToUser(atVC viewController: UIViewController, errorDescriptionToUser: String) {
        let alertController = UIAlertController(
            title: "Произошла ошибка",
            message: errorDescriptionToUser,
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Ok", style: .default))

        viewController.present(alertController, animated: true)
    }
}
