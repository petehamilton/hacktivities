class Repository < ActiveRecord::Base
  belongs_to :hackathon

  validates :user, :name, :original_url, :presence => true
  validates :original_url, :uniqueness => true

  def user
    uri = URI.parse(original_url)
    uri.path.split('/')[1]
  end

  def name
    uri = URI.parse(original_url)
    uri.path.split('/')[2]
  end

  def commits_url
    "https://api.github.com/repos/#{user}/#{name}/commits"
  end
end
