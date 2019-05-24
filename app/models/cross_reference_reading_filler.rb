class CrossReferenceReadingFiller
  #  ActiveRecord::Base.logger.level = 1
  def initialize
    File.readlines("xref_kanji.txt").each do |line|
      xref, sense_id = line.split
      original_sense = Sense.find(sense_id)
      puts "considering #{xref} #{original_sense.glosses}"
      middot_split = xref.split("・")
      puts "searching kanji for #{middot_split.first}"
      entries = Entry.alternate_find_by(middot_split.first)
      entries.each_with_index do |entry, e_index|
        entry.senses.each_with_index do |sense, s_index|
          puts "#{e_index} #{s_index} #{sense.glosses}"
        end
      end
      if entries.any?
        e_index, s_index = prompt("Which is it? ").split
        next if e_index == 'next'
        cross_reference_sense = entries[e_index.to_i].senses[s_index.to_i]
        CrossReference.create(sense_id: original_sense.id, cross_reference_sense_id: cross_reference_sense.id)
      end
      puts "\n"
    end
  end

  def prompt(*args)
    print(*args)
    gets
  end
end
