//
//  DetailViewModel.swift
//  Aspyre
//

import Combine

final class DetailViewModel: ObservableObject {
    
    @Published private(set) var owner: OwnerPhoto?
    
    private let galleryService: GalleryServiceType
    private var cancellable = Set<AnyCancellable>()
    
    init(galleryService: GalleryServiceType) {
        self.galleryService = galleryService
    }
    
    func getDetail(id: String) {
        galleryService.getBy(id: id)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    self.owner = OwnerPhoto(from: response)
                }
            )
            .store(in: &cancellable)
    }
}

extension DetailViewModel {
    static func make() -> DetailViewModel {
        DetailViewModel(galleryService: Injector.resolve(GalleryServiceType.self))
    }
}
