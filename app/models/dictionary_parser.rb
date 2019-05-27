class DictionaryParser
  def initialize(file_name)
    # Create a new parser
    puts "Deleting all Entries and Senses"
    Entry.delete_all
    Sense.delete_all
    handler = OgaSax.new
    Oga.sax_parse_xml(handler, File.open(file_name))
    puts "Entry.count: #{Entry.count}"
    puts "Sense.count: #{Sense.count}"
  end
end
