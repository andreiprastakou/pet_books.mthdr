import jQuery from 'jquery'
import CoverDesign from 'store/coverDesigns/api/CoverDesign'

class ApiClient {
  static getCoverDesigns() {
    return jQuery.ajax({
      url: '/api/cover_designs.json'
    }).then(list => list.map(entry => CoverDesign.parse(entry)))
  }
}

export default ApiClient
