//
//  SceneDelegate.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 04.08.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var mainCoordinator: CoordinatorProtocol? ///чтобы сохранялась связь после выхода из области видимости

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: scene)
        let mainCoordinator = MainCoordinator()
        window.rootViewController = mainCoordinator.start()

        self.window = window
        self.mainCoordinator = mainCoordinator
        window.makeKeyAndVisible()
    }

//    private enum TabItemType {
//        case ticketsList
//        case details
//
//        var title: String {
//            switch self {
//            case .ticketsList:
//                return "Авиабилеты"
//            case .details:
//                return "Детали перелета"
//            }
//        }
//
//        var tabBarItem: UITabBarItem {
//            switch self {
//            case .ticketsList:
//                return UITabBarItem(title: "Список", image: UIImage(named: "List"), tag: 0)
//            case .details:
//                return UITabBarItem(title: "Детали", image: UIImage(systemName: "airplane.departure"), tag: 1)
//            }
//        }
//    }
//
//
//    private func createNavigationControllerFor(_ tabItemType: TabItemType) -> UINavigationController {
//        let viewController: UIViewController
//
//        switch tabItemType {
//        case .ticketsList:
//            viewController = TicketsViewController()
//        case .details:
//            viewController = DetailsViewController()
//        }
//
//        viewController.title = tabItemType.title
//        viewController.tabBarItem = tabItemType.tabBarItem
//        return UINavigationController(rootViewController: viewController)
//    }
//
//    private func createTabBarController() -> UITabBarController {
//        let tabBarController = UITabBarController()
//        UITabBar.appearance().backgroundColor = Styles.lightGrayColor
//        tabBarController.viewControllers = [
//            createNavigationControllerFor(.ticketsList),
//            createNavigationControllerFor(.details)
//        ]
//
//        tabBarController.selectedIndex = 0
//        return tabBarController
//    }
}



