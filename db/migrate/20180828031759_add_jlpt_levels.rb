class AddJlptLevels < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :jlpt_level, :integer
  end
end
