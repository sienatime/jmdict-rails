class OgaSax
   # * `on_document`
  # * `on_doctype`
  # * `on_cdata`
  # * `on_comment`
  # * `on_proc_ins`
  # * `on_xml_decl`
  # * `on_text(text)
  # * `on_element(namespace, name, attrs = {})
  # * `on_element_children`
  # * `on_attribute`
  # * `on_attributes`
  # * `after_element(namespace, name)

  def on_element(namespace, name, attrs = {})
    @current_name = name
    case name
    when "entry"
      @entry = Entry.new
    when "sense"
      @entry.senses.build
    end
  end

  def after_element(namespace, name)
    if (name == "entry")
      @entry.save!
    end
  end

  def on_text(text)
    data = finesse(text)
    return if data.blank?
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
    str[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
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
      semicolon_separated_string += ";#{data}"
    end
  end

  def add_kanji(kanji)
    if first_kanji?
      @entry.primary_kanji = kanji
    else
      @entry.other_kanji = add_with_tab(@entry.other_kanji, kanji)
    end
  end

  def add_reading(reading)
    if first_reading?
      @entry.primary_reading = reading
    else
      @entry.other_readings = add_with_tab(@entry.other_readings, reading)
    end
  end

  def first_kanji?
    @entry.primary_kanji.nil?
  end

  def first_reading?
    @entry.primary_reading.nil?
  end
end
