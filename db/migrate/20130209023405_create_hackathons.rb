class CreateHackathons < ActiveRecord::Migration
  def up
    create_table :hackathons do |t|
      t.string :name
    end
  end

  def down
    drop_table :hackathons
  end
end
