//
//  TicketsCoordinator.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 11.08.2023.
//

import Foundation
import UIKit

protocol TicketsCoordinatorProtocol: AnyObject {
    func pushDetailsVC(model: TicketForUI, delegateLike2to1: LikeDelegate2to1, indexPath: IndexPath)
}


final class TicketsCoordinator {

    // MARK: - Private properties
    private var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Private methods
    private func createTicketsVC() -> UIViewController {
        let networkManager = NetworkManager(networkRouter: NetworkRouter(), mapper: DataMapper())
        let dataTransformer = DataTransformer(networkManager: networkManager)
        let viewModel = TicketsViewModel(coordinator: self, dataTransformer: dataTransformer)

        let ticketsVC = TicketsViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: ticketsVC)
        navigationController = navController
        return navigationController
    }

    private func createDetailsVC(model: TicketForUI, likeDelegate2to1: LikeDelegate2to1, indexPath: IndexPath) -> UIViewController {
        let detailsViewModel = DetailsViewModel(
            detailTicketModel: model,
            delegate: likeDelegate2to1, // 7 для передачи лайка
            indexPath: indexPath
        )
        let detailVC = DetailsViewController(viewModel: detailsViewModel)
        detailVC.title = "Детали"
        return detailVC
    }

}

// MARK: - CoordinatorProtocol
extension TicketsCoordinator: CoordinatorProtocol {
    func start() -> UIViewController {
        let vc = createTicketsVC()
        return vc
    }
}

extension TicketsCoordinator: TicketsCoordinatorProtocol {
    /// когда во VC нажмем на ячейку, то вызываем viewModel.didTapCell(indexPath: indexPath), и тогда  viewModel у себя в didTapCell требует TicketsCoordinator'а запушить-открыть DetailsVC:
    func pushDetailsVC(model: TicketForUI, delegateLike2to1: LikeDelegate2to1, indexPath: IndexPath) {
        let vc = createDetailsVC(model: model, likeDelegate2to1: delegateLike2to1, indexPath: indexPath)
        navigationController.pushViewController(vc, animated: true)
    }
}
