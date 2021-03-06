

import Foundation
import UIKit

protocol APIResponseDelegate: AnyObject{
    
    func completedApiRequest()
    
    func showError()
    
    func statusAPIRequest()
}
class HomeViewModel {
    
    public weak var delegate: APIResponseDelegate?
    
    let apiService: APIServiceProtocol
    
    private var topStories: [Article] = [Article]()
    
    private var cellViewModels: [TopArticleListCellViewModel] = [TopArticleListCellViewModel]() {
        didSet {
            self.delegate?.completedApiRequest()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.delegate?.statusAPIRequest()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.delegate?.showError()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var selectedTopStory: TopArticleDetailsViewModel?
    
    
    init( apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch() {
        self.isLoading = true
        apiService.fetchTopStories { [weak self] (success, results, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.localizedDescription
            } else {
                self?.processFetchedTopStories(topStories: results)
            }
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> TopArticleListCellViewModel {
        
        return cellViewModels[indexPath.row]
        
    }
    
    func createCellViewModel( topStory: Article ) -> TopArticleListCellViewModel {
        
        let multimedia = topStory.imageGallery?.filter{
            $0.imageFormat == ImageSize.thumbLarge
        }
        
        let imageUrl =  (multimedia?.count) ?? 0  > 0 ? multimedia?[0].imageUrl : ""
        
        return TopArticleListCellViewModel(titleText: topStory.newsTitle , authorText: topStory.newsByLine ?? "" , imageUrl: imageUrl ?? "")
    }
    
    private func processFetchedTopStories( topStories: [Article] ) {
        
        self.topStories = topStories // Cache
        var vms = [TopArticleListCellViewModel]()
        for topStory in topStories {
            vms.append( createCellViewModel(topStory: topStory) )
        }
        self.cellViewModels = vms
    }
    
}

extension HomeViewModel {
    
    func userPressed( at: Int ) -> TopArticleDetailsViewModel? {
        
        let topStory = self.topStories[at]
        let multimedia = topStory.imageGallery?.filter{
            $0.imageFormat == ImageSize.mediumThreeByTwo210
        }
        let imageUrl =  (multimedia?.count ?? 0) > 0 ? multimedia?[0].imageUrl : ""
        var dateString = ""
        if (topStory.newsPublishedDate != nil){
            guard let dateArray = topStory.newsPublishedDate?.components(separatedBy: "T") else { return nil }
            
            dateString = dateArray.count > 0 ? dateArray[0]  : ""
        }
        self.selectedTopStory = TopArticleDetailsViewModel(titleText: topStory.newsTitle , authorText: topStory.newsByLine ?? "", imageUrl: imageUrl ?? "", dateText: dateString, detailsText: topStory.newsAbstract , seeMoreLink: topStory.newsWebUrl , subSection: topStory.newSubsection)
        
        return self.selectedTopStory
    }
}

struct TopArticleListCellViewModel {
    
    let titleText: String
    let authorText: String
    let imageUrl: String
}

struct TopArticleDetailsViewModel {
    
    let titleText: String
    let authorText: String
    let imageUrl: String
    let dateText: String
    let detailsText :String
    let seeMoreLink : String
    let subSection : String
    
}
