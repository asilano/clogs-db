class CreateMailingListsMembers < ActiveRecord::Migration
  def change
    create_table :mailing_lists_members, id: false do |t|
      t.integer :mailing_list_id
      t.integer :member_id
    end

    add_index :mailing_lists_members, :mailing_list_id
    add_index :mailing_lists_members, :member_id
  end
end
