import UIKit

class PokemonViewController: UIViewController {
    
    
    var name: String! //Create global name variable for user defaults
    var url: String!
    var caught: Bool! //Set global caught variable
    let defaults = UserDefaults.standard //Call user defaults
    var spriteURL: URL!
    var spriteData: Data!
    var spriteImage: UIImage!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchLabel: UIButton!
    @IBOutlet var spriteImageView: UIImageView!
    
    @IBAction func toggleCatch() {
        if caught == false {
            catchLabel.setTitle("Release", for: .normal)
            caught = true
            defaults.set(caught, forKey:name)
        } else if caught == true {
            catchLabel.setTitle("Catch", for: .normal)
            caught = false
            defaults.set(caught, forKey:name)
        }
    }
    
    

    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""

        loadPokemon()
        
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async { [self] in
                    self.name = result.name
                    self.navigationItem.title = self.capitalize(text: self.name)
                    self.nameLabel.text = self.capitalize(text: self.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    
                    self.spriteURL = URL(string: result.sprites.front_default)
                    
                    do {
                        self.spriteData = try Data(contentsOf: self.spriteURL)
                    } catch _ {
                        self.spriteData = nil
                    }
                    
                    self.spriteImage = UIImage(data: self.spriteData)
                    
                    self.spriteImageView.image = spriteImage
                    
                    self.caught = self.defaults.bool(forKey: result.name)
                    
                    if self.caught == true {
                        self.catchLabel.setTitle("Release", for: .normal)
                    } else {
                        self.catchLabel.setTitle("Catch", for: .normal)
                    }
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
