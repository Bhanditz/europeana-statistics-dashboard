class Core::ArticlesController < ApplicationController
  before_action :set_core_article, only: [:show, :edit, :update, :destroy]

  # GET /core_articles
  # GET /core_articles.json
  def index
    @core_articles = @core_project.core_articles.all
  end

  # GET /core_articles/1
  # GET /core_articles/1.json
  def show
  end

  # GET /core_articles/new
  def new
    @core_article = Core::Article.new
  end

  # GET /core_articles/1/edit
  def edit
  end

  # POST /core_articles
  # POST /core_articles.json
  def create
    @core_article = Core::Article.new(core_article_params)
    if @core_article.save
      redirect_to account_core_project_article_path(@account, @core_project), notice: t("c.s")
    else
      render :new
    end
  end

  # PATCH/PUT /core_articles/1
  # PATCH/PUT /core_articles/1.json
  def update
    if @core_article.update(core_article_params)
      redirect_to account_core_project_article_path(@account, @core_project), notice: t("u.s")
    else
      render :edit
    end
  end

  # DELETE /core_articles/1
  # DELETE /core_articles/1.json
  def destroy
    @core_article.destroy
    redirect_to account_core_project_article_path(@account, @core_project), notice: t('d.s')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_core_article
      @core_article = Core::Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def core_article_params
      params.require(:core_article).permit(:core_project_id, :name, :created_by, :updated_by, :status)
    end
end
