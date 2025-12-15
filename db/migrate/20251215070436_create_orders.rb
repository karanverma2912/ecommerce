class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_amount
      t.string :shipping_address
      t.integer :status, default: 0, null: false
      t.integer :payment_status, default: 0, null: false
      t.string :payment_method
      t.string :stripe_payment_id

      t.timestamps
    end
  end
end
