# senses has_many cross_references

# - めどが立つ・めどがたつ;めどが立たない
# - 顧みる・1
# - 離岸流・りがんりゅう
# - 夕暮れ・ゆうぐれ
# - 期する・ごする・2
# - 期する・ごする・3
# - そもそも・2
# - 溜まる・たまる
# - 上客・じょうきゃく・2
# - 掛け値・かけね・2
# - 倶利迦羅竜王

class CrossReferenceAdder
  attr_reader :senses

  def initialize
    @senses = Sense.where.not(cross_references: nil)
  end

  def go
    senses.find_each do |sense|
      original_sense = sense

      xrefs = sense.cross_references.split(";")
      xrefs.each do |xref|
        ref = xref.split("・")
        expression = ref.first
        index = find_sense_index(ref)
        entry = find_by_kanji_or_reading(expression, ref)

        if entry
          assign_to_sense(original_sense, entry, index, xref)
        else
          alternates = Entry.alternate_find_by(expression)
          if alternates.size == 1
            assign_to_sense(original_sense, alternates.first, index, xref)
          elsif alternates.count > 1
            log_xref(xref, original_sense)
            puts "** too many alternates"
            puts "*** alternates.count #{alternates.count}"
            puts "*** alternates.map ids #{alternates.map(&:id)}"
          else
            log_xref(xref, original_sense)
            puts "** no alternates/entry found"
          end
        end
      end
    end
  end

  private

  def log_xref(xref, original_sense)
    puts "\n"
    puts "xref: #{xref} #{original_sense.id} #{original_sense.glosses}"
  end

  def find_sense_index(ref)
    possible_index = ref.last
    if possible_index.to_i > 0
      possible_index.to_i - 1 # they are all 1-indexed
    else
      -1
    end
  end

  def find_by_kanji_or_reading(expression, ref)
    kanji, reading, index = ref
    entry = Entry.find_by(primary_kanji: kanji, primary_reading: reading)
    return entry if entry.present?
    entries = Entry.where(primary_kanji: expression)
    return entries.first if entries.any?
    entries = Entry.where(primary_reading: expression, primary_kanji: nil) # this is more likely to be an exact match than the next one
    return entries.first if entries.size == 1
    entries = Entry.where(primary_reading: expression).where.not(primary_kanji: nil) # could be a lot of things
    return entries.first if entries.size == 1
  end

  def find_sense_by_index(entry, index)
    if entry.senses.size == 1
      entry.senses.first
    elsif index > -1
      entry.senses[index] # this could still be nil
    end
  end

  def assign_to_sense(original_sense, entry, index, xref)
    if sense = find_sense_by_index(entry, index)
      create_cross_reference(original_sense, sense, xref)
    else
      sense = try_exact_match(original_sense, entry)
      create_cross_reference(original_sense, sense, xref)
    end
  end

  def try_exact_match(original_sense, entry)
    exact_match = entry.senses.find { |sense| sense.glosses == original_sense.glosses }
    return exact_match if exact_match.present?
    entry.senses.first # oh well
  end

  def create_cross_reference(original_sense, sense, xref)
    if CrossReference.find_by(sense_id: original_sense.id, cross_reference_sense_id: sense.id).nil?
      CrossReference.create(sense_id: original_sense.id, cross_reference_sense_id: sense.id)
      puts "\n"
      puts "created xref: #{xref} | #{sense.glosses} | #{original_sense.id} | #{sense.id}"
    end
  end
end

# Example: bx rails runner /Users/siena/workspace/nanodegree/capstone/jmdict_to_sqlite/jmdict/app/models/cross_reference_adder.rb > xref_out.txt

if __FILE__ == $0
  $stdout.sync = true
  puts "#{Time.now}: File: #{__FILE__}"
  puts "CrossReference.count: #{CrossReference.count}"
  CrossReferenceAdder.new.go
  puts "CrossReference.count: #{CrossReference.count}"
  puts "#{Time.now}: Done"
end
