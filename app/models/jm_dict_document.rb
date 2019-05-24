class JMDictDocument < Nokogiri::XML::SAX::Document
  def start_element(name, attributes = [])
    @current_name = name
    case name
    when "entry"
      @entry = Entry.new
    when "sense"
      @entry.senses.build
    end
  end

  def end_element(name)
    if (name == "entry")
      @entry.save!
    end
  end

  def characters(str)
    data = finesse(str)
    case @current_name
    when "keb"
      add_kanji(data)
    when "reb"
      add_reading(data)
    when "pos"
      add_to_last_sense(data, :parts_of_speech)
    when "gloss"
      add_to_last_sense(data, :glosses)
    when "xref"
      add_to_last_sense(data, :cross_references)
    when "stagk"
      add_to_last_sense(data, :applies_to)
    end
  end

  private

  def string_between_markers(str)
    marker1 = "&"
    marker2 = ";"
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end

  def finesse(str)
    if str.starts_with?("&")
      string_between_markers(str).strip
    else
      str.strip
    end
  end

  def add_to_last_sense(data, attr)
    sense = @entry.senses.last
    sense[attr] = add_with_tab(sense[attr], data).strip
  end

  def add_with_tab(semicolon_separated_string, data)
    if semicolon_separated_string.blank?
      data
    else
      semicolon_separated_string += "\t#{data}"
    end
  end

  def add_kanji(kanji)
    if first_kanji?
      @entry.primary_kanji = kanji
    else
      add_with_tab(@entry.other_kanji, kanji)
    end
  end

  def add_reading(reading)
    if first_reading?
      @entry.primary_reading = reading
    else
      add_with_tab(@entry.other_readings, reading)
    end
  end

  def first_kanji?
    @entry.primary_kanji.nil?
  end

  def first_reading?
    @entry.primary_reading.nil?
  end
end
