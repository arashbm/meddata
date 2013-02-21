class Keyword < ActiveRecord::Base
  has_many :article_keywords
  has_many :articles, :through => :article_keywords
  attr_accessible :title
  
  def save_keyword_occurrence!(ids=nil)
    articles = ids ? Article.where(id: ids) : Article
    aks=[]
    aid= article_ids
    articles.basic_search(title).each do |article|
      unless aid.include?(article.id)
        aks << article_keywords.new(article_id: article.id)
      end
    end
    ArticleKeyword.import aks
  end

  def neighborhood
    unless @neighborhood 
      mu_ids = {}
      kwds = find(articles.all.map{ |i| i.keyword_ids }.flatten.uniq)
      kwds.each do |mu|
        mu_ids[mu.id] = (find(mu).article_ids & article_ids)
      end
      @neighborhood = mu_ids.map{ |k,v| v.size}
    end
  end
end
