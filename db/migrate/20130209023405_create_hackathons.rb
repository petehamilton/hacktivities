class CreateHackathons < ActiveRecord::Migration
  def up
    create_table :hackathons do |t|
      t.string :name
      t.integer :twitter_widget_id
    end
  end

  def down
    drop_table :hackathons
  end
end
