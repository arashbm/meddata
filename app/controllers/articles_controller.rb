class ArticlesController < ApplicationController
  respond_to :html, :json, :js
  def index
    @articles = Article.order('created_at DESC').page(params[:page]).per_page(20)
    respond_with(@articles)
  end

  def show
    @article = Article.find(params[:id])
    respond_with(@article)
  end

  def new
    @article = Article.new
    respond_with(@article)
  end

  def edit
    @article = Article.find(params[:id])
  end

  def create
    @article = Article.new(params[:article])
    @article.save
    respond_with(@article)
  end

  def update
    @article = Article.find(params[:id])
    @article.update_attributes(params[:article])
    respond_with(@article)
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    respond_with(@article)
  end
end
