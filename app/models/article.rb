class Article < ActiveRecord::Base
  attr_accessible :abstract, :pubmed_id, :raw_pubmed_xml, :title
end
