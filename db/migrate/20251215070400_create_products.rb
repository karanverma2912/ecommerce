class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :sku
      t.integer :quantity_in_stock
      t.references :category, null: false, foreign_key: true
      t.boolean :is_active, default: true
      t.integer :discount_percentage, default: 0

      t.timestamps
    end
  end
end
