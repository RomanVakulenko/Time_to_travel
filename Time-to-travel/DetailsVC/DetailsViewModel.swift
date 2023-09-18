//
//  DetailViewModel.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 09.08.2023.
//

import Foundation

protocol LikesDelegate2to1: AnyObject {
    func passLikeTo1vc(at indexPath: IndexPath)
}

// MARK: - Enum
enum DetailsState { //чтобы использовать в протоколе надо выносить в глобальный контекст??
    case none
}

protocol DetailsViewModelProtocol: AnyObject { //protocolCoverage так надо делать??
    var closureChangeState: ((DetailsState) -> Void)? { get set }
    var oneTicketModel: FlightTicket { get set }
    func didTapLikeButton()
}

final class DetailsViewModel: DetailsViewModelProtocol {


     // MARK: - Public properties
    var closureChangeState: ((DetailsState) -> Void)?
    internal var oneTicketModel: FlightTicket


    // MARK: - Private properties
    private weak var delegateLike2to1: LikesDelegate2to1?

    private var currentIndexPath: IndexPath

    private var state: DetailsState = .none {
        didSet {
            closureChangeState?(state)
        }
    }

    // MARK: - Lifecycle
    init(ticketModel: FlightTicket, delegate: LikesDelegate2to1?, indexPath: IndexPath) {
        self.oneTicketModel = ticketModel
        self.delegateLike2to1 = delegate
        self.currentIndexPath = indexPath
    }

    // MARK: - Public methods
    func didTapLikeButton() {
        delegateLike2to1?.passLikeTo1vc(at: currentIndexPath)
    }

}

