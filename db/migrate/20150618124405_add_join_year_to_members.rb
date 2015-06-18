class AddJoinYearToMembers < ActiveRecord::Migration
  def change
    add_column :members, :join_year, :integer, allow_nil: true
  end
end
