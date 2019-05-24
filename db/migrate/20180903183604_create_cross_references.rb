class CreateCrossReferences < ActiveRecord::Migration[5.2]
  def change
    create_table :cross_references do |t|
      t.integer :sense_id, null: false
      t.integer :cross_reference_sense_id, null: false
    end

    add_index :cross_references, :sense_id
    add_index :entries, :jlpt_level
  end
end
