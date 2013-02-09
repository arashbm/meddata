class ArticleKeyword < ActiveRecord::Base
  belongs_to :article
  belongs_to :keyword
  # attr_accessible :title, :body
end
