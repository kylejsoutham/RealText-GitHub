//
//  ViewController.swift
//  RealText
//
//  Created by Kyle Southam on 26/06/20.
//

import Cocoa
import SQLite3
//import CSVImporter

let dbPath: String = "myDb.sqlite"
var db:OpaquePointer?

let debug = true
var phrases = [String]()
let users = ["Sco`t`t","Dave","Harry","Biff"]
var populatedbrequired: Bool = false
var recordcount = 1 // the number of records in the CSV file\
//
// Text statistics
//
var wordcount = 0
//
// MACROS
// %BEDROOMS%
// %STOREYS%
// %SQM%
// %DWELLING%
// %BATHS%
// %STYLE%

// Software
let software_release_version = 1.0
let software_author = "Kyle Southam"
let software_name = "Real Text"

class ViewController: NSViewController,NSTableViewDelegate,NSTableViewDataSource {

    override func viewDidLoad() {
       // print ("Before View")
        super.viewDidLoad()
        //print ("After View")
        // Do any additional setup after loading the view.
        
        
        phrases = ["Scott","Dave","Harry","Biff"]
        db = openDatabase()
        //if populatedbrequired { dropTable() }
        
        //insertintodb(section: "View",subsection: "Harbour",words: "a view across the water", hits: 0,category: "SLUG")
        
        //
        // Populate the database
        //
        if populatedbrequired {
            if debug {
                print ("Read Data from CSV")
            }
                readDataFromCSV()
        }
        // Clean up the combo box first
        
        //
        // Set up combo boxes
        SlugSectionCombo.removeAllItems()
        transitionComboBox.removeAllItems()
        
        populatesluglinesectioncombo()
        // populate intro box
        populatetransitioncombobox()
        // populate location
        populatelocationcombobox()
        // wrap up
        populatewrapupcombobox()
        // view
        populateviewcombobox()
        // amenities
        populateamenitiescombobox()
        // dwelling
        populatedwellingcombobox()
        
        SlugSectionCombo.isEditable = false
        //SlugSubsectionCombo.isEditable = false
       
        SlugSectionCombo.numberOfVisibleItems = 10
        //SlugSubsectionCombo.numberOfVisibleItems = 10
       
        
        tableView.delegate = self
             tableView.dataSource = self
        print ("View Loaded")
       
    }
    
   
    
  //
  // CSV
    

    func readDataFromCSV(){
        var dataArray : [String] = []
     
       // here we have to have an alert pop up
       
       print ("In Read Data from CSV")
       dropTable()
       createTable()
        
        print ("Opening CSV")
       
       // let paths = FileManager.default.urls(for: .tmp, in: .userDomainMask)
          //  let documentsDirectory = paths[0]
        //print ("Documents = \(documentsDirectory)")
        var path: String
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a file to Import";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
             path = result!.path
                
                // path contains the file path e.g
                // /Users/ourcodeworld/Desktop/file.txt
    
        
          
               
               dataArray = []
               recordcount = 1
               print ("Selected dialog filename = \(path)")
               
               do {
                  let url = URL(fileURLWithPath: path)
                   let data = try Data(contentsOf: url)
                   let dataEncoded = String(data: data, encoding: .utf8)
                   if  let dataArr = dataEncoded?.components(separatedBy: "\r\n").map({ $0.components(separatedBy: ",") })
                   {
                   for line in dataArr
                    {
                    dataArray.append(contentsOf: line)
                    var section = line[0];
                    var subsection = line[1]
                    var words = line[2]
                    var hits = Int(line[3]) ?? 0
                    var category = line[4]
                
                    print ("Section = \(section) - Subsection = \(subsection) words = \(words) category = \(category)")
                    print ("Inserting into DB Row -> \(recordcount)")
                    recordcount = recordcount + 1
                   insertintodb(section: section,subsection: subsection,words: words,hits:hits,category: category)
                  
                   }
                }
               }
               catch let jsonErr {
                   print("\n Error read CSV file: \n ", jsonErr)
               }
        }
        
      
    }
    
    @IBAction func copyButtonClicked(_ sender: NSButton) {
        // when the tableview window is clicked then add the text to the compilation window
        // print ("Number of rows in table view = \(tableView.numberOfRows) selected row = \(tableView.selectedRow)")
        //
        // Make sure there are rows in the table view or do absolutely nothing
        //
        if (tableView.selectedRow <= 0 ) {
            // Do nothing
        } else
        {
            print (tableView.selectedRow)
            print (phrases[tableView.selectedRow])
            let words = phrases[tableView.selectedRow] + " "
           // let replaced = replace_macros(text: words as String)
            //
           //print ("Word = \(words) replaced = \(replaced)")
            // add to the compilation window
            //
            Compilation.documentView!.insertText(words)
    }
    }
    
    
    
    func replace_macros (text: String) -> String {
        var replaced: String
        //var replaced: String
        //print ("Replacing macros...")
        //print ("Value of bedroom index = \(numberofBedroomsCombo.indexOfSelectedItem)")
       
        
      //  replaced = text.replacingOccurrences(of: "%BEDROOM%", with: numberofBedroomsCombo.itemObjectValue(at: numberofBedroomsCombo.indexOfSelectedItem) as! String)
            //return replaced as String
       return "abc"
    }
  
    func numberOfRows(in tableView: NSTableView) -> Int {
        return phrases.count
       }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
           //let todo = "Hello"
           
        var cellValue: String = ""
           var cellIdentifier = NSUserInterfaceItemIdentifier("")
        var replaced: String = ""
           if tableColumn?.identifier.rawValue == "itemColumn" {
               //cellValue = phrases[row];
           // print ("Setting Cell value for Row - > \(row) with \(phrases[row])")
            cellValue = phrases[row];
            // cellValue = replace_macros(text: cellValue)
           // print ("Cell Value = \(cellValue)")
               cellIdentifier = NSUserInterfaceItemIdentifier("itemCell")
            
           }
           
           if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
               
            //replaced = replace_macros(cellValue: Te)
            //print (type(of: cellValue))
            //
            // ---- setup for Macro Replacement
            //
            
            cell.textField?.stringValue = cellValue
            //print ("Cell = \(cell.textField)")

               return cell
           }
           
           return nil
       }
  

    @IBOutlet weak var tableView: NSTableView!

    
  
    
   
  
    @IBOutlet weak var transitionComboBox: NSComboBox!
    
    @IBOutlet weak var locationComboBox: NSComboBox!
    
   
    @IBOutlet weak var dwellingComboBox: NSComboBox!
    @IBOutlet weak var SlugWordsCombo: NSComboBox!
    @IBOutlet weak var SlugSectionCombo: NSComboBoxCell!
    
    @IBOutlet weak var SlugSubsectionCombo: NSComboBox!
    
    @IBOutlet weak var amenitiesComboBox: NSComboBox!
    
    @IBOutlet weak var viewComboBox: NSComboBox!
    @IBOutlet weak var wrapupComboBox: NSComboBox!
    @IBOutlet weak var Compilation: NSScrollView!
    
   // @IBAction func SlugTextComboSelect(_ sender: NSComboBoxCell) {
    //    print(SlugText.itemObjectValue(at: SlugText.indexOfSelectedItem))
    //   var text = SlugText.itemObjectValue(at: SlugText.indexOfSelectedItem)
    //    text = text as! String + "\r\n" + "\r\n"
    //    Compilation.documentView!.insertText(text)
        
   // }
    func populatedwellingcombobox () {
        dwellingComboBox.removeAllItems()
                let queryStatementString = "SELECT DISTINCT section FROM words where category=\"DWELLING\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                print ("Adding > \(section) to wrap up combo!")
                dwellingComboBox.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        //SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
    }
    
    func populateamenitiescombobox () {
        amenitiesComboBox.removeAllItems()
        let queryStatementString = "SELECT DISTINCT section FROM words where category=\"AMENITIES\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                print ("Adding > \(section) to wrap up combo!")
                amenitiesComboBox.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        //SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
    }
    
    func populateviewcombobox () {
        viewComboBox.removeAllItems()
        let queryStatementString = "SELECT DISTINCT section FROM words where category=\"VIEW\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                print ("Adding > \(section) to wrap up combo!")
                viewComboBox.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        //SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
    }
    
    func populatewrapupcombobox () {
        wrapupComboBox.removeAllItems()
        let queryStatementString = "SELECT DISTINCT section FROM words where category=\"WRAPUP\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                print ("Adding > \(section) to wrap up combo!")
                wrapupComboBox.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        //SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
    }
        
    func populatelocationcombobox () {
        locationComboBox.removeAllItems()
        let queryStatementString = "SELECT DISTINCT section FROM words where category=\"LOCATION\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                //let subsection = String(cString: sqlite3_column_text(queryStatement, 1))
               // let section = String(cString: sqlite3_column_text(queryStatement, 1))
               // let subsection = String(decoding: UnsafePointer<UInt8>sqlite3_column_text(queryStatement, 2), as: UTF8.self)
                
                
                //let words =  String(cString: sqlite3_column_text(queryStatement, 2))
               //  let subsection = String(cString:queryResultCol1!)
                 //print("Query Result:")
                 //print("\(section)")
                //
                // Add to the combo box
                //
                locationComboBox.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        //SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
     }
  
  
    func populatetransitioncombobox () {
        transitionComboBox.removeAllItems()
        let queryStatementString = "SELECT DISTINCT section FROM words where category=\"TRANSITION\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                //let subsection = String(cString: sqlite3_column_text(queryStatement, 1))
               // let section = String(cString: sqlite3_column_text(queryStatement, 1))
               // let subsection = String(decoding: UnsafePointer<UInt8>sqlite3_column_text(queryStatement, 2), as: UTF8.self)
                
                
                //let words =  String(cString: sqlite3_column_text(queryStatement, 2))
               //  let subsection = String(cString:queryResultCol1!)
                 //print("Query Result:")
                 //print("\(section)")
                //
                // Add to the combo box
                //
                transitionComboBox.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        //SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
     }
  
    func populatesluglinesectioncombo () {
        SlugSectionCombo.removeAllItems()
        let queryStatementString = "SELECT DISTINCT section FROM words where category=\"SLUG\" order by section ASC;"
        var queryStatement: OpaquePointer? = nil
        
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                let section = String(cString: sqlite3_column_text(queryStatement, 0))
                //let subsection = String(cString: sqlite3_column_text(queryStatement, 1))
               // let section = String(cString: sqlite3_column_text(queryStatement, 1))
               // let subsection = String(decoding: UnsafePointer<UInt8>sqlite3_column_text(queryStatement, 2), as: UTF8.self)
                
                
                //let words =  String(cString: sqlite3_column_text(queryStatement, 2))
               //  let subsection = String(cString:queryResultCol1!)
                 //print("Query Result:")
                 print("\(section)")
                //
                // Add to the combo box
                //
                SlugSectionCombo.addItem(withObjectValue: section)
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
        //SlugSectionCombo.stringValue = SlugSectionCombo.selectItem(at: 0)
        SlugSectionCombo.stringValue=SlugSectionCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
     }
    
    
   
    func populate_phrase_view (selectedword: String,queryStatementString: String) {
        // search for the selected word from the main combo box
        //var arr = String()
        var words: String?
        //SlugWordsCombo.removeAllItems()
       // SlugWordsCombo.stringValue=""
        
        phrases = []
        phrases.removeAll()
        
        print (queryStatementString);
        var queryStatement: OpaquePointer? = nil
      
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                words = String(cString:sqlite3_column_text(queryStatement,0))
         
                 //print("Words = \(words)")
                //
                // Add to the combo box
                //
               // arr.append(subsection)
            
                
               // print ("Building Phrases array:-> \(words) with a length of \(phrases.count)")
                phrases.append(words ?? "BLANK");
               
                
    
                //SlugSubsectionCombo.addItem(withObjectValue: "Cheese")
                //
                
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
       // print ("Array Contents = \(arr)")
        // put the first value in the combo box
        //SlugWordsCombo.stringValue=SlugWordsCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
    // Database Functions
        tableView.reloadData()
        //tableView.isHidden = false
    }
    
    
    
    func populatewordscombo (selectedword: String,queryStatementString: String) {
        // search for the selected word from the main combo box
        //var arr = String()
        var words: String?
        SlugWordsCombo.removeAllItems()
        SlugWordsCombo.stringValue=""
        
        phrases = []
        phrases.removeAll()
        
        print (queryStatementString);
        var queryStatement: OpaquePointer? = nil
      
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
             while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                words = String(cString:sqlite3_column_text(queryStatement,0))
         
                 //print("Words = \(words)")
                //
                // Add to the combo box
                //
               // arr.append(subsection)
            
                
                SlugWordsCombo?.addItem(withObjectValue: words)
             //   print ("Building Phrases array:-> \(words) with a length of \(phrases.count)")
                phrases.append(words ?? "BLANK");
               
                
    
                //SlugSubsectionCombo.addItem(withObjectValue: "Cheese")
                //
                
             }
                
         } else {
             print("SELECT statement could not be prepared")
         }

         sqlite3_finalize(queryStatement)
       // print ("Array Contents = \(arr)")
        // put the first value in the combo box
        //SlugWordsCombo.stringValue=SlugWordsCombo.itemObjectValue(at: 0) as? String ?? "SELECT"
    // Database Functions
        tableView.reloadData()
            // tableView.isHidden = false
    }
    
    func insertintodb(section:String, subsection:String, words:String,hits:Int,category: String)
    {
       
        let insertStatementString = "INSERT INTO words (section,subsection,words,hits,category) VALUES (?, ?, ?,?,?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (section as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (subsection as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (words as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(hits))
            sqlite3_bind_text(insertStatement, 5, (category as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
               print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    
    
    func dropTable() {
            let dropTableString = "DROP TABLE words;"
            var dropTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, dropTableString, -1, &dropTableStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(dropTableStatement) == SQLITE_DONE
                {
                    print("words table dropped.")
                } else {
                    print("words table could not be dropped.")
                }
            } else {
                print("DROP TABLE statement could not be prepared.")
            }
            sqlite3_finalize(dropTableStatement)
        }
    
    func createTable() {
            let createTableString = "CREATE TABLE IF NOT EXISTS words(section TEXT,subsection TEXT,words TEXT,hits INTEGER,category STRING);"
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(createTableStatement) == SQLITE_DONE
                {
                  //  print("words table created.")
                    //tablenewlycreated = true
                } else {
                 //   print("words table could not be created.")
                }
            } else {
                print("CREATE TABLE statement could not be prepared.")
            }
            sqlite3_finalize(createTableStatement)
        }
    
    func openDatabase() -> OpaquePointer?
        {
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(dbPath)
            var db: OpaquePointer? = nil
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK
            {
                print("error opening database")
                return nil
            }
            else
            {
             //   print("Successfully opened connection to database at \(dbPath)")
                return db
            }
    }
    
    @IBAction func dwellingSelectionCombo(_ sender: NSComboBoxCell) {
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = dwellingComboBox.indexOfSelectedItem
        selecteditem1 = dwellingComboBox.itemObjectValue(at: ind1) as! String
        
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"DWELLING\";"
        
        print ("location selection = \(qs)")
        //print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        
    }
    
    @IBAction func amenitiesSelectionCombo(_ sender: NSComboBoxCell) {
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = amenitiesComboBox.indexOfSelectedItem
        selecteditem1 = amenitiesComboBox.itemObjectValue(at: ind1) as! String
        
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"AMENITIES\";"
        
        print ("location selection = \(qs)")
        //print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        

    }
    
    @IBAction func viewSelectionCombo(_ sender: NSComboBoxCell) {
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = viewComboBox.indexOfSelectedItem
        selecteditem1 = viewComboBox.itemObjectValue(at: ind1) as! String
        
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"VIEW\";"
        
        print ("location selection = \(qs)")
        //print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        
    }
    
    @IBAction func wrapupSelectionCombo(_ sender: NSComboBox) {
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = wrapupComboBox.indexOfSelectedItem
        selecteditem1 = wrapupComboBox.itemObjectValue(at: ind1) as! String
        
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"WRAPUP\";"
        
      //  print ("location selection = \(qs)")
        //print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        
    }
    
    @IBAction func locationSelectionCombo(_ sender: NSComboBoxCell) {
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = locationComboBox.indexOfSelectedItem
        selecteditem1 = locationComboBox.itemObjectValue(at: ind1) as! String
        
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"LOCATION\";"
        
      // print ("location selection = \(qs)")
        //print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        
    }
    
    
    @IBAction func transitionSelectionCombo(_ sender: NSComboBoxCell) {
        // populate the text view
        
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = transitionComboBox.indexOfSelectedItem
        selecteditem1 = transitionComboBox.itemObjectValue(at: ind1) as! String
        
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"TRANSITION\";"
        print ("In transition and selected = \(qs)")
        //print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        
    }
    
    @IBAction func SlugSelectionCombo(_ sender: NSComboBox) {
        // take the selected item
        // then lookup the database
        var queryStatementString: String
        var selecteditem1: String
        
        let ind1 = SlugSectionCombo.indexOfSelectedItem
        selecteditem1 = SlugSectionCombo.itemObjectValue(at: ind1) as! String
        
        //let ind2 = //SlugSubsectionCombo.indexOfSelectedItem
        //let selecteditem2 = //SlugSubsectionCombo.itemObjectValue(at: ind2)
        
        let qs = "SELECT words FROM words where section = \"" + selecteditem1  + "\" AND category = \"SLUG\";"
        
       // print ("SlugSection = \(selecteditem1)")
       // populatewordscombo(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        populate_phrase_view(selectedword: selecteditem1 as! String, queryStatementString: qs as! String)
        
               
    }
    
   
    
   

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }



    
    }

