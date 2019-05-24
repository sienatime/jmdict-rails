class ConvertVarcharToText < ActiveRecord::Migration[5.2]
  def up
    change_column :entries, :primary_kanji, :text
    change_column :entries, :primary_reading, :text
    change_column :entries, :other_kanji, :text
    change_column :entries, :other_readings, :text

    change_column :senses, :parts_of_speech, :text
    change_column :senses, :glosses, :text
    change_column :senses, :applies_to, :text
    change_column :senses, :cross_references, :text
  end

  def down
    change_column :entries, :primary_kanji, :string
    change_column :entries, :primary_reading, :string
    change_column :entries, :other_kanji, :string
    change_column :entries, :other_readings, :string

    change_column :senses, :parts_of_speech, :string
    change_column :senses, :glosses, :string
    change_column :senses, :applies_to, :string
    change_column :senses, :cross_references, :string
  end
end
