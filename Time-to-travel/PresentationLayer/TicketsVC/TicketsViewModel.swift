//
//  TicketsViewModel.swift
//  time-to-travel
//
//  Created by Roman Vakulenko on 08.08.2023.
//

import Foundation

// MARK: - Protocols
//protocol NetworkAPIProtocol: AnyObject {
//    func getTicketsUsingAPI() async throws -> [TicketForUI]
//}

protocol TicketsViewModelProtocol: AnyObject {
    var closureChangeState: ((TicketsViewModel.State) -> Void)? { get set }
    var ticketsListModel: [TicketForUI] { get set }

    func requestTickets()
    func didTapCell(at indexPath: IndexPath)
    func updateLikeState(_ isLiked: Bool, at indexPath: IndexPath)
}

final class TicketsViewModel {

    // MARK: - Enum
    enum State {
        case none
        case loading
        case loaded
        case reloadItems(at: [IndexPath])
        case wrong(alertText: String)
    }

    // MARK: - Public properties
    /// благодаря клоужеру мы bindимся (в связи - bind вся суть MVVM )
    var closureChangeState: ((State) -> Void)?
    var ticketsListModel: [TicketForUI] = []

    // MARK: - Private properties
    private var likeAtIndexPath = false
    private weak var coordinator: TicketsCoordinatorProtocol?
    private var dataTransformer: DataTransformerProtocol

    private var state: State = .none {
        didSet {
            closureChangeState?(state)
        }
    }

    // MARK: - Init
    init(coordinator: TicketsCoordinatorProtocol?, dataTransformer: DataTransformerProtocol) {
        self.coordinator = coordinator
        self.dataTransformer = dataTransformer
    }
}

// MARK: - NetworkAPIProtocol
// GCD + Completion
//    func networkAPI(completion: @escaping ([TicketForUI]) -> Void) {
//        let networkConcurrentQueue = DispatchQueue(label: "networkConcurrentQueue", qos: .userInitiated, attributes: .concurrent) //чтобы не грузить global
//
//        networkConcurrentQueue.async { [weak self] in
//            guard let self else {return}
//
//            self.dataTransformer.makeTicketsFromData { result in // тут послаблять? или выше надо?
//                switch result {
//                case .success(let ticketsForUI):
//                    DispatchQueue.main.async {
//                        completion(ticketsForUI)
//                    }
//                case .failure(let error):
//                    self.state = .wrong(alertText: error.descriptionForUser)
//                }
//            }
//        }
//    }
// }

// MARK: - TicketsViewModelProtocol
extension TicketsViewModel: TicketsViewModelProtocol {
@MainActor /// вся функция будет выполняться только MainActor'ом в главном потоке
    func requestTickets() {
        state = .loading /// в клоужер closureChangeState передается state - говорим - идет загрузка
        Task {/// MainActor приостанавливает выполнение и  делает свою основную работу, пока Task не вернет результат - как вернет результат, тогда MainActor обновит инфу на главном потоке
            do {
                guard let url = EndPont.shared.urlFor(variant: .pricesForLatest) else {
                    throw NetWorkManagerErrors.networkRouterError(error: .badURL)
                }

                let tickets = try await dataTransformer.makeTicketsFromData(at: url)
                self.ticketsListModel = tickets /// . ...мы обновим модель данных (а до этого момента коллекция пустая) загруженными из сети данными
                self.state = .loaded /// и пепердаем в клоужер closureChangeState state , чтобы он его принял и во VC совершил нужные дейстия согласно этому state
            } catch {
                switch error {
                case NetWorkManagerErrors.networkRouterError(error: .badURL):
                    print("NetworkRouter caught error: \(RouterErrors.badURL)")
                    state = .wrong(alertText: "Неизвестная ошибка")

                case NetWorkManagerErrors.networkRouterError(error: .noInternetConnection):
                    print("NetworkRouter caught error: \(RouterErrors.noInternetConnection)")// себе
                    state = .wrong(alertText: NetWorkManagerErrors.show.descriptionForUser) // юзер увидит "Ошибка соединения с сервером"

                case NetWorkManagerErrors.networkRouterError(error: .serverErrorWith(let code)):
                    print("Bad server response - \(code.description)")
                    state = .wrong(alertText: "Ошибка сервера")

                case NetWorkManagerErrors.mapperError(error: let reason):
                    print("MapperError caught in TicketsViewModel - \(reason.description)")
                    state = .wrong(alertText: "Неизвестная ошибка")

                default:
                    print("TicketsViewModel default caught error: \(error)")
                }
            }
        }

    }

    /// так VC передает состояние лайка в свою viewModel, чтобы передать лайк на 2ой экран
    func updateLikeState(_ isLiked: Bool, at indexPath: IndexPath) {
        ticketsListModel[indexPath.item].isLike = isLiked // в модель по indexPath записали состояние лайка
        likeAtIndexPath = isLiked // чтобы передать лайк на 2ой (после нажатия на 1ом)
    }

    /// VC в didSelectItemAt вызывает этот метод у ViewModel, а она говорит координатору - открой мне экран: (вызывает метод координатора - pushDetailsVC и передает в него следующие параметры)
    func didTapCell(at indexPath: IndexPath) {
        let modelAtIndexPath = ticketsListModel[indexPath.item]
        likeAtIndexPath = modelAtIndexPath.isLike
        print("В ticketsViewModel likeAtIndexPath - \(likeAtIndexPath)")

        coordinator?.pushDetailsVC(
            model: modelAtIndexPath,
            delegateLike2to1: self, // 6 TicketsViewModel - делегат DetailsViewModelи, чтобы реализовать ниже метод протокола LikeDelegate2to1 и установить лайк
            indexPath: indexPath // чтобы потом передать лайк со 2ого на 1ый
        )
    }
}

// MARK: - LikesDelegate
extension TicketsViewModel: LikeDelegate2to1 {

    func passLikeTo1vc(at indexPath: IndexPath, likeStateFromDetail: Bool) {// 5
        ticketsListModel[indexPath.item].isLike = likeStateFromDetail/// like из Detail записываем в модель
        print("Like in TicketsViewModel became - \(ticketsListModel[indexPath.item].isLike)")
        state = .reloadItems(at: [indexPath])
    }
}
