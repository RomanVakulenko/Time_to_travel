//
//  DetailViewModel.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 09.08.2023.
//

import Foundation

// MARK: - Protocols
protocol DetailsViewModelProtocol: AnyObject {
    var oneTicketModel: TicketForUI { get set }
    func didTapLikeButton(changedLike: Bool)
}

protocol LikeDelegate2to1: AnyObject {
    func passLikeTo1vc(at indexPath: IndexPath, likeStateFromDetail: Bool) // 1
}

final class DetailsViewModel: DetailsViewModelProtocol {

    // MARK: - Public properties
    var oneTicketModel: TicketForUI

    // MARK: - Private properties
    private weak var delegateLike2to1: LikeDelegate2to1?// 2
    private var currentIndexPath: IndexPath// 2

    // MARK: - Lifecycle
    init(detailTicketModel: TicketForUI, delegate: LikeDelegate2to1?, indexPath: IndexPath) {
        self.oneTicketModel = detailTicketModel
        self.delegateLike2to1 = delegate
        self.currentIndexPath = indexPath// 3
    }

    // MARK: - Public methods
    func didTapLikeButton(changedLike: Bool) {
        delegateLike2to1?.passLikeTo1vc(at: currentIndexPath, likeStateFromDetail: changedLike)// 4
    }
}
