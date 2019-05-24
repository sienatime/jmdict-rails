class Entry < ApplicationRecord
  has_many :senses

  def self.by_kanji(kanji)
    Entry.find_by(primary_kanji: kanji)
  end

  def self.where_r(reading)
    Entry.where(primary_reading: reading)
  end

  def self.where_k(kanji)
    Entry.where(primary_kanji: kanji)
  end

  def lvl(level)
    self.update!(jlpt_level: level)
  end

  def self.match(data, attr)
    /^#{data}$|^#{data};|;#{data}$|;#{data};/.match(attr)
  end

  def self.alternate_find_by(expression)
    found_by_kanji = Entry.where("other_kanji LIKE ?", "%#{expression}%").select do |entry|
      self.match(expression, entry.other_kanji)
    end
    return found_by_kanji if found_by_kanji.any?
    Entry.where("other_readings LIKE ?", "%#{expression}%").select do |entry|
      self.match(expression, entry.other_readings)
    end
  end
end
