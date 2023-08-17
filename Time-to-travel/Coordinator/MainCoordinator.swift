//
//  MainCoordinator.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 11.08.2023.
//

import Foundation
import UIKit

final class MainCoordinator {

    // MARK: - Private properties
    private var childCoordinator: [CoordinatorProtocol] = [] ///хранит ссылки на координаторы, иначе при выходе из области видимости функции start потеряем ссылки на координаторов (когда main создает дочерние или дочерние создают еще свои дочерние)

    // MARK: - Private methods
    private func makeTicketsCoordinator() -> CoordinatorProtocol { ///т.к. координатор может состоять из кучи объектов, то лучше обернуть в метод
        let coordinator1VC = TicketsCoordinator(navigationController: UINavigationController()) ///создали координатор c navController
        return coordinator1VC
    }

    private func addChildCoordinator(_ coordinator1VC: CoordinatorProtocol) {
        guard !childCoordinator.contains(where: { $0 === coordinator1VC }) else { return } ///сравниваем адреса памяти, ссылается ли объект на тот же адрес памяти (т.е. до тех пор пока координаторов нет - добавляй их)
        childCoordinator.append(coordinator1VC)
    }

}

extension MainCoordinator: CoordinatorProtocol {

    func start() -> UIViewController {
        let ticketsCoordinator = makeTicketsCoordinator()
        addChildCoordinator(ticketsCoordinator)
        return ticketsCoordinator.start() ///этот VC мы возвращаем в sceneDelegate
    }

}

