
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

   private enum Tickets: String {
        case forPeriod = "/v2/prices/latest" //Цены на авиабилеты за период
        case fakeRequest = "fakeURLPath"
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
            delegate: self, // зачем??...self это TicketsViewModel, т.е. TicketsViewModel - это делегат DetailsViewModelи?, это чтобы реализовать ниже метод протокола LikesDelegate2to1 и установить лайк?
            indexPath: indexPath
        )
    }

    // MARK: - Private methods
    /// [TicketForUI] -> [FlightTicket]
    public func getTickets(uiTickets: [TicketForUI]) -> [FlightTicket] { //ГДЕ ЛУЧШЕ РАЗМЕЩАТЬ ЭТОТ МЕТОД?
        var resultArray: [FlightTicket] = []
        for number in 0..<uiTickets.count {
            let newTicket = FlightTicket(
                city1: "\(uiTickets[number].city1)",
                city2: "\(uiTickets[number].city2)",
                departureDate: getDate(fromString: uiTickets[number].departureDateString) ?? Date(),
                arrivalDate: getDate(fromString: uiTickets[number].arrivalDateString) ?? Date(),
                price: uiTickets[number].price,
                isLike: false
            )
            resultArray.append(newTicket)
        }
        return resultArray
    }

    /// dateFormatter (String) -> Date
    private func getDate(fromString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: fromString)
    }


    private func mockNetworkAPI(completion: @escaping ([FlightTicket]) -> Void) { //сетевой слой
        let networkQueue = DispatchQueue.global(qos: .utility)
        networkQueue.async { //загружаем асинхронно
            let networkManager = NetworkManager()
            networkManager.fetchData(ticketsOptions: Tickets.forPeriod.rawValue) { [weak self] ticketsData in
                if let flightTickets = self?.getTickets(uiTickets: ticketsData) {
                    DispatchQueue.main.async {
                    //тут записываем в модель
                        completion(flightTickets) ///т.к. этот метод будет вызван в итоге во VC, то надо вернуть в главный поток; а. передали в клоужер массив билетов
                    }
                }
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
