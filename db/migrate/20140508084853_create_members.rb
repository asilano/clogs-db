class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :forename
      t.string :surname
      t.string :addr1
      t.string :addr2
      t.string :addr3
      t.string :town
      t.string :county
      t.string :postcode
      t.string :phone
      t.string :mobile
      t.string :voice
      t.string :membership
      t.string :email
      t.boolean :subs_paid
      t.boolean :show_fee_paid
      t.boolean :concert_fee_paid

      t.timestamps null: true
    end
  end
end
