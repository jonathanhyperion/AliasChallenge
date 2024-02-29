//
//  GalleryViewModel.swift
//  Aspyre
//

import Foundation
import Combine

final class GalleryViewModel: ObservableObject {
    
    // MARK: - Declarations
    
    @Published private(set) var photos: [Photo] = []
    @Published private(set) var showEmptyState = false
    
    private let galleryService: GalleryServiceType
    private var cancellable = Set<AnyCancellable>()
    private(set) var contactName = Constants.empty
    private(set) var page = Constants.initialPage
    private var totalPages = Constants.zero
    
    
    // MARK: - Init/Deinit
    
    init(galleryService: GalleryServiceType) {
        self.galleryService = galleryService
    }
    
    // MARK: - Public Methods
    
    func setContact(name: String) {
        contactName = name
        reload()
    }
    
    func reload() {
        page = Constants.initialPage
        photos.removeAll()
        getPhotos()
    }
    
    func areMorePhotosAvailable() -> Bool {
        (page + 1) <= totalPages
    }
    
    func loadMore() {
        page += 1
        getPhotos()
    }
    
    // MARK: - Helpers
    
    private func getPhotos() {
        galleryService
            .getAll(
                name: contactName,
                page: page
            )
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    
                    let items = response.result.photos
                    
                    self.showEmptyState = items.isEmpty
                    self.photos += items
                    self.totalPages = response.result.pages
                }
            )
            .store(in: &cancellable)
    }
}

extension GalleryViewModel {
    static func make() -> GalleryViewModel {
        GalleryViewModel(galleryService: Injector.resolve(GalleryServiceType.self))
    }
}
