class ArticleExtractorWorker
  include Sidekiq::Worker

  def read_list(list_file)
    File.read(list_file).split
  end

  def perform(ids, list_file)
    list = read_list list_file
    ids.each do |i|
      Article.find(i).extract_keywords_from_list(list)
    end
  end

end
