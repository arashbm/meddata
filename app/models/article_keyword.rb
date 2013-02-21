class ArticleKeyword < ActiveRecord::Base
  belongs_to :article
  belongs_to :keyword
  attr_accessible :kayword_id, :article_id
end
