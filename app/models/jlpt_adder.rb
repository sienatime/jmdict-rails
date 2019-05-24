class JlptAdder
  # file = "lib/jlptn2.txt"
  # JlptAdder.new("lib/jlptn2.txt")
  attr_reader :level

  def initialize(file_name, level)
    @level = level
    File.readlines(file_name).each do |line|
      tokens = line.split
      if tokens.size == 2
        kanji, reading = tokens
        find_by(kanji, reading)
      elsif tokens.size == 1
        reading = tokens.first
        find_by(nil, reading)
      else
        puts "unknown tokens of size #{tokens.size}: #{tokens.inspect}"
      end
    end
  end

  def primary_attrs(kanji, reading)
    if kanji.nil? || kanji == reading
      { primary_reading: reading }
    else
      { primary_kanji: kanji, primary_reading: reading }
    end
  end

  def find_by(kanji, reading)
    entries = Entry.where(primary_attrs(kanji, reading))
    used_alternate = false
    if entries.empty?
      entries = alternate_find_by(kanji, reading)
      used_alternate = true
    end

    if entries.empty?
      puts "NOT FOUND #{kanji} #{reading}"
    else
      if entries.count > 1
        entries.each_with_index do |entry, i|
          puts "#{i} #{entry.primary_kanji} #{entry.primary_reading}"
        end
        e_index = prompt("Which is it? #{kanji} #{reading}")
        return if e_index == 'next'
        assign(entries[e_index.to_i], kanji, reading, used_alternate, level)
      else
        entries.each do |entry|
          assign(entry, kanji, reading, used_alternate, level)
        end
      end
    end
  end

  def assign(entry, kanji, reading, used_alternate, level)
    if entry.jlpt_level.nil? || (entry.jlpt_level.present? && entry.jlpt_level < level)
      puts "assigning: #{entry.primary_kanji} #{entry.primary_reading} to #{kanji} #{reading} ALT? #{used_alternate}"
      entry.update!(jlpt_level: level)
    end
  end

  def match(data, attr)
    /^#{data}$|^#{data};|;#{data}$|;#{data};/.match(attr)
  end

  def alternate_find_by(kanji, reading)
    if kanji.present?
      Entry.where("other_kanji LIKE ?", "%#{kanji}%").select do |entry|
        match(kanji, entry.other_kanji)
      end
    else
      Entry.where("other_readings LIKE ?", "%#{reading}%").select do |entry|
        match(reading, entry.other_readings)
      end
    end
  end

  def prompt(*args)
    print(*args)
    gets
  end
end

# Example: bx rails runner /Users/siena/workspace/nanodegree/capstone/jmdict_to_sqlite/jmdict/app/models/jlpt_adder.rb > jlpt_test_out.txt

if __FILE__ == $0
  $stdout.sync = true
  puts "#{Time.now}: File: #{__FILE__}"
  JlptAdder.new("lib/jlptn1.txt", 1)
  puts "#{Time.now}: Done"
end
