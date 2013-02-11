class CreateHackathons < ActiveRecord::Migration
  def up
    create_table :hackathons do |t|
      t.string :name
      t.string :twitter_widget_id
      t.integer :redbull_cans_drunk, :default => 0
      t.integer :pizzas_eaten, :default => 0
    end
  end

  def down
    drop_table :hackathons
  end
end
