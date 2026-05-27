import SwiftUI

@Observable
@MainActor
final class MapViewModel {
    var searchText             = ""
    var isLoading              = false
    var errorMessage: String?
    var filterOptions          = FilterOptions()
    var isFilterSheetPresented = false
    var isProfilePresented     = false
    var isSubmitPresented      = false

    // TODO: Fetch washrooms from WashroomRepository based on current map region
    // TODO: Cache results into SwiftData via modelContext
    // TODO: Apply filterOptions to query predicates
    // TODO: Implement full-text search against cached washrooms
}
