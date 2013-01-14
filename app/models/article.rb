class Article < ActiveRecord::Base
  attr_accessible :abstract, :pubmed_id, :raw_pubmed_xml, :title
  
  def extract_pubmed_title
    doc = Nokogiri.XML(raw_pubmed_xml)
    doc.css('PubmedArticle MedlineCitation Article ArticleTitle').first.try(:text)
  end

  def extract_pubmed_abstract
    doc = Nokogiri.XML(raw_pubmed_xml)
    doc.css('PubmedArticle MedlineCitation Article Abstract AbstractText').first.try(:text)
  end

  def extract_pubmed_data!
    update_attributes title: extract_pubmed_title, abstract: extract_pubmed_abstract
  end
end
