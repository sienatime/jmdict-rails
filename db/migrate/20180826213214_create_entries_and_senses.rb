class CreateEntriesAndSenses < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.string :primary_kanji
      t.string :primary_reading, null: false
      t.string :other_kanji
      t.string :other_readings
      t.datetime :created_at, null: false
    end

    create_table :senses do |t|
      t.belongs_to :entry, null: false
      t.string :parts_of_speech
      t.string :glosses, null: false
      t.string :applies_to
      t.string :cross_references
      t.datetime :created_at, null: false
    end
  end
end
