
//
//  TicketsViewModel.swift
//  time-to-travel
//
//  Created by Илья Сидорик on 08.08.2023.
//

import Foundation

final class TicketsViewModel {

    // MARK: - Enum
    enum State { ///мин для работы с сетью, но может быть больше состояний
        case none
        case loading
        case loaded
        case reloadItems(at: [IndexPath])
        case wrong(errorDescription: String)
    }

    // MARK: - Public properties
    ///благодаря клоужеру мы bindимся (в связи - bind вся суть MVVM )
    var closureChangeState: ((State) -> Void)?

    private(set) var ticketsListModel: [FlightTicket] = []

    // MARK: - Private properties
    private weak var coordinator: TicketsCoordinator?
    private weak var networkManager: NetworkManagerProtocol?

    private var state: State = .none { ///none - т.к. пока не значем что будет происходить, а каждый раз как будем изменять State - будем вызывать клоужер
        didSet {
            closureChangeState?(state)
        }
    }

    // MARK: - Init
    init(coordinator: TicketsCoordinator?) {
        self.coordinator = coordinator
    }


    // MARK: - Public methods
    func requestTickets() {
        state = .loading ///в клоужер closureChangeState передается state - сказали - идет загрузка
        mockNetworkAPI { tickets in ///как только придет массив билетов(из сети), тогда...б. массив билетов приняли от сетевого слоя
            self.ticketsListModel = tickets ///. ...мы обновим модель данных (а до этого момента коллекция пустая) загруженными из сети данными
            self.state = .loaded /// и пепердаем в клоужер closureChangeState state , чтобы он его принял и во VC совершил нужные дейстия согласно этому state
        }
    }

    func didTapCell(indexPath: IndexPath) {
        let model = ticketsListModel[indexPath.item]
        /// VC в didSelectItemAt вызывает этот метод у ViewModel, а она в свою очередь говорит координатору - открой мне экран: (вызывает метод координатора - pushDetailsVC и передает в него следующие параметры)
        coordinator?.pushDetailsVC(
            model: model,
            delegate: self, // зачем?...self это TicketsViewModel, типа TicketsViewModel - делегат DetailsViewModelи?, чтобы реализовать ниже метод протокола LikesDelegate2to1 - чтобы установить лайк?
            indexPath: indexPath
        )
    }

    // MARK: - Private methods
    private func mockNetworkAPI(completion: @escaping ([FlightTicket]) -> Void) { //сетевой слой

        let networkQueue = DispatchQueue.global(qos: .utility)
        networkQueue.async { //загружаем асинхронно
            let networkManager = NetworkManager()
            let data = networkManager.fetchData(ticketsOptions: Tickets.forPeriod.rawValue) { tickets in
                print(tickets)

                //парсим
//                DispatchQueue.main.async {
                //или тут парсим и записываем в модель
//                    completion(model) ///т.к. этот метод будет вызван в итоге во VC, то надо вернуть в главный поток; а. передали в клоужер массив билетов
//                }
            }

        }
    }
}

// MARK: - LikesDelegate
extension TicketsViewModel: LikesDelegate2to1 {

    func passLikeTo1vc(at indexPath: IndexPath) {
        ticketsListModel[indexPath.item].isLike.toggle() ///переключаем состояние лайка в модели данных
        state = .reloadItems(at: [indexPath])
    }
}



