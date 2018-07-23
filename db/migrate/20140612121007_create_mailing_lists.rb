class CreateMailingLists < ActiveRecord::Migration
  def change
    create_table :mailing_lists do |t|
      t.string :name, null: false

      t.timestamps null: true
    end
    add_index :mailing_lists, :name, :unique => true
  end
end
