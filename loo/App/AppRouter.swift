import SwiftUI

enum AppRoute: Hashable {
    case detail(washroomID: String)
    case finder(washroomID: String)
    case submit
    case editSubmission(washroomID: String)
    case profile
}

@Observable
@MainActor
final class AppRouter {
    var path               = NavigationPath()
    var isAuthPresented    = false
    var isFilterPresented  = false
    var selectedWashroom: Washroom?

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
