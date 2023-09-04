//
//  TicketsCoordinator.swift
//  Time-to-travel
//
//  Created by Roman Vakulenko on 11.08.2023.
//

import Foundation
import UIKit

final class TicketsCoordinator {

    // MARK: - Private properties
    private var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Private methods
    private func makeTicketsVC() -> UIViewController {
        let viewModel = TicketsViewModel(coordinator: self)
        let ticketsVC = TicketsViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: ticketsVC)
        navigationController = navController
        return navigationController
    }

    private func makeDetailsVC(model: FlightTicket, delegate: LikesDelegate2to1, indexPath: IndexPath) -> UIViewController {
        let detailsViewModel = DetailsViewModel(
            ticketModel: model,
            delegate: delegate, //зачем тут указывать делегата??
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
        let vc = makeTicketsVC()
        return vc
    }
    /// когда во VC нажмем на ячейку, то вызываем viewModel.didTapCell(indexPath: indexPath), и тогда  viewModel у себя в didTapCell требует TicketsCoordinator'а запушить-открыть DetailsVC
    func pushDetailsVC(model: FlightTicket, delegate: LikesDelegate2to1, indexPath: IndexPath) {
        let vc = makeDetailsVC(model: model, delegate: delegate, indexPath: indexPath) //зачем делегат??
        navigationController.pushViewController(vc, animated: true)
    }
}

