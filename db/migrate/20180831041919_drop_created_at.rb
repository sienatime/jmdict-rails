class DropCreatedAt < ActiveRecord::Migration[5.2]
  def up
    remove_column :entries, :created_at
    remove_column :senses, :created_at
  end

  def down
    add_column :entries, :created_at, :datetime, null: false
    add_column :senses, :created_at, :datetime, null: false
  end
end
