
import Foundation
import CoreLocation

protocol weatherMangerDelegate {
    func didUpdateWeather(_ weatherManger : WeatherManager, weather : WeatherModel)
    func didFailWithError(error : Error)
    
}


struct WeatherManager {
    var delegate : weatherMangerDelegate?
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=360c3f364a4169f466fe5cc22d716012&units=metric"
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(lat : CLLocationDegrees , lon : CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    //MARK: - creating URL Session
    func performRequest(with urlString : String){

        if let url = URL(string: urlString) {

            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                }
                if let safeData = data {
                    if let weather = self.parseJson(safeData){
                        self.delegate?.didUpdateWeather(self , weather: weather)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    
    func parseJson(_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(temp: temp, cityName: name, conditionId: id)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
    
    
}
