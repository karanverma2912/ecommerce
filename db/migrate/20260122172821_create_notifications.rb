class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.datetime :read_at
      t.jsonb :data, default: {}
      t.string :category
      t.references :notifiable, polymorphic: true, null: true

      t.timestamps
    end
  end
end
