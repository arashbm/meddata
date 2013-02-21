class ArticleExtractorWorker
  include Sidekiq::Worker

  def read_list(list_file)
    File.readlines(list_file).map(&:chomp).uniq
  end

  def perform(list_file, ids = nil)
    list = read_list(list_file)
    list.each do |term|
      keyword = Keyword.find_or_create_by_title(term)
      keyword.save_keyword_occurrence!(ids)
    end
  end

end
