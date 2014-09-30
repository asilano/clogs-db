class AddQueryToMailingLists < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :query, :text
  end
end
