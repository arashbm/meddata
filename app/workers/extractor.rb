class ArticleExtractorWorker
  include Sidekiq::Worker

  def read_list(list_file)
    File.readlines(list_file).map(&:chomp).uniq
  end

  def perform(list_file, ids = nil)
    list = read_list(list_file)
    list.each do |term|
      Article.save_keyword_occurrence(term, ids)
    end
  end

end
