namespace :db do
  desc 'create database from the full dictionary XML file'
  task populate: :environment do
    file = 'lib/JMdict_e'
    DictionaryParser.new(file)
  end

  desc 'create database from a smaller XML file'
  task populate_sample: :environment do
    file = 'lib/jmdict_sample.xml'
    DictionaryParser.new(file)
  end
end
