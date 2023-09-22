
//
//  TicketsViewModel.swift
//  time-to-travel
//
//  Created by Илья Сидорик on 08.08.2023.
//

import Foundation

protocol NetworkAPIProtocol: AnyObject {
    func networkAPI(completion: @escaping ([FlightTicket]) -> Void)
}

protocol TicketsViewModelRequestProtocol: AnyObject {
    func requestTickets()
}

protocol TicketsViewModelTapCellProtocol: AnyObject {
    func didTapCell(indexPath: IndexPath)
}

// MARK: - Enum
enum State { ///мин для работы с сетью, но может быть больше состояний
    case none
    case loading
    case loaded
    case reloadItems(at: [IndexPath])
    case wrong(errorDescription: String)
}

protocol TicketsViewModelProtocol: TicketsViewModelRequestProtocol, TicketsViewModelTapCellProtocol {

    var closureChangeState: ((State) -> Void)? { get set }
    var ticketsListModel: [FlightTicket] { get set }

}


final class TicketsViewModel {

   private enum Tickets: String {
        case forPeriod = "/v2/prices/latest" //Цены на авиабилеты за период
        case fakeRequest = "fakeURLPath"
    }

    // MARK: - Public properties
    ///благодаря клоужеру мы bindимся (в связи - bind вся суть MVVM )
    var closureChangeState: ((State) -> Void)?

    var ticketsListModel: [FlightTicket] = []

    // MARK: - Private properties
    private weak var coordinator: TicketsCoordinator?
    private var networkManager: NetworkManagerProtocol? // ??убрал weak; если weak,ТО на 98стр xCode писал, что Instance will be immediately deallocated because property 'networkManager' is 'weak' //protocolCoverage так надо делать?

    private var state: State = .none { ///none - т.к. пока не значем что будет происходить, а каждый раз как будем изменять State - будем вызывать клоужер
        didSet {
            closureChangeState?(state)
        }
    }

    // MARK: - Init
    init(coordinator: TicketsCoordinator?) {
        self.coordinator = coordinator
    }

    // MARK: - Private methods
    /// [TicketForUI] -> [FlightTicket]
    private func getTickets(uiTickets: [TicketForUI]) -> [FlightTicket] { //ГДЕ ЛУЧШЕ РАЗМЕЩАТЬ ЭТОТ МЕТОД??
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

//    /// dateFormatter (String) -> Date
//    private func getDate(fromString: String) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dateFormatter.timeZone = TimeZone.current
//        dateFormatter.locale = Locale.current
//        return dateFormatter.date(from: fromString)
//    }

}

// MARK: - NetworkAPIProtocol
extension TicketsViewModel: NetworkAPIProtocol {

    internal func networkAPI(completion: @escaping ([FlightTicket]) -> Void) { //сетевой слой
        let networkConcurrentQueue = DispatchQueue(label: "networkConcurrentQueue", qos: .userInitiated, attributes: .concurrent) //т.к. global очереди системные и загрузив их еще можем потерять скорость - потому своя конкурентная очередь

        networkConcurrentQueue.async { [weak self] in //загружаем асинхронно //нужен ли weak self??утечка?? или нет, потому что кложур не
            self?.networkManager = NetworkManager()
            //поскольку URLSession работает асинхронно, то вызов dataTask не надо заворачивать в еще какую-то очередь //удалить созданную networkConcurrentQueue очередь??
            self?.networkManager?.fetchData(ticketsOptions: Tickets.forPeriod.rawValue) { ticketsData in
                if let flightTickets = self?.getTickets(uiTickets: ticketsData) { //нужен ли нужен ли weak self??утечка??
                    DispatchQueue.main.async {// возвращаем в UI - т.е. на главный поток
                        completion(flightTickets) ///т.к. этот метод будет вызван в итоге во VC, то надо вернуть в главный поток; а. передали в клоужер массив билетов
                    }
                }
            }
        }
    }
// пробовал написать через async await, но получал ошибки в процессе загрузки APP, связанные с главным потоком
//    internal func networkAPI(completion: @escaping ([FlightTicket]) -> Void) { //сетевой слой
//        Task { [weak self] in
//            self?.networkManager = NetworkManager()
//            try await self?.networkManager?.fetchData(ticketsOptions: Tickets.forPeriod.rawValue) { [weak self] ticketsData in
//                if let flightTickets = self?.getTickets(uiTickets: ticketsData) {
//                    completion(flightTickets) ///т.к. этот метод будет вызван в итоге во VC, то надо вернуть в главный поток; а. передали в клоужер массив билетов
//                }
//            }
//        }
//    }

}

// MARK: - TicketsViewModelProtocol
extension TicketsViewModel: TicketsViewModelProtocol {

    func requestTickets() {
        state = .loading ///в клоужер closureChangeState передается state - сказали - идет загрузка
        networkAPI { tickets in ///как только придет массив билетов(из сети), тогда...б. массив билетов приняли от сетевого слоя
            self.ticketsListModel = tickets ///. ...мы обновим модель данных (а до этого момента коллекция пустая) загруженными из сети данными
            self.state = .loaded /// и пепердаем в клоужер closureChangeState state , чтобы он его принял и во VC совершил нужные дейстия согласно этому state
        }
    }

    func didTapCell(indexPath: IndexPath) {
        let model = ticketsListModel[indexPath.item]
        /// VC в didSelectItemAt вызывает этот метод у ViewModel, а она в свою очередь говорит координатору - открой мне экран: (вызывает метод координатора - pushDetailsVC и передает в него следующие параметры)
        coordinator?.pushDetailsVC(
            model: model,
            delegate: self, // зачем?? TicketsViewModel - делегат DetailsViewModelи, чтобы реализовать ниже метод протокола LikesDelegate2to1 и установить лайк?
            indexPath: indexPath
        )
    }

}



// MARK: - LikesDelegate
extension TicketsViewModel: LikesDelegate2to1 {

    func passLikeTo1vc(at indexPath: IndexPath) {
        ticketsListModel[indexPath.item].isLike.toggle() ///переключаем состояние лайка в модели данных
        state = .reloadItems(at: [indexPath])
    }
}


