class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :categories, :slug, unique: true
  end
end
