class Core::ConfigurationEditorsController < ApplicationController
  
  before_action :sudo_project_member!
  before_action :set_configuration_editor, only: [:show, :edit, :update, :destroy, :publish]

  def index
    @configuration_editors = @core_project.configuration_editors.page params[:page]
  end

  def show
  end

  def new
    @enable_express_tour = true
    @configuration_editor = Core::ConfigurationEditor.new
  end

  def edit
  end

  def create
    @configuration_editor = Core::ConfigurationEditor.new(core_configuration_editor_params)
    respond_to do |format|
      if @configuration_editor.save
        format.html { redirect_to account_core_project_configuration_editors_path(@account,@core_project), notice: t("c.s") }
        format.json { render :show, status: :created, location: @configuration_editor }
      else
        format.html { render :new }
        format.json { render json: @configuration_editor.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    contents = JSON.parse(params[:core_configuration_editor][:content])
    name= params[:core_configuration_editor][:name]
    @configuration_editor = @configuration_editor || params[:id]
    if Core::ConfigurationEditor.find(@configuration_editor).update(content: contents)
      redirect_to account_core_project_configuration_editors_path(@account,@core_project), notice: t("u.s")
    else
      @configuration_editor = @core_project.configuration_editors.find(params[:id])
      flash.now.alert = t("u.f")
      render :edit
    end    
  end

  def destroy
    if @configuration_editor.cdn_published_url.present? #PUBLISH TO CDN Functionality
      @configuration_editor.update_attributes(marked_to_be_deleted: "true")
      Core::S3File::DestroyWorker.perform_async("ConfigurationEditor", @configuration_editor.id)
      redirect_to account_core_project_configuration_editors_path(@core_project.account, @core_project), notice: t("d.m")
    else
      @configuration_editor.destroy
      redirect_to account_core_project_configuration_editors_path(@core_project.account, @core_project), notice: t("d.s")
    end
  end
  
  def publish #PUBLISH TO CDN Functionality
    Core::S3File::UploadWorker.perform_async("ConfigurationEditor", @configuration_editor.id,nil)
    redirect_to :back, notice: t("publish")
  end

  private

  def set_configuration_editor
    @configuration_editor = @core_project.configuration_editors.where(slug: params[:id]).first
  end

  def core_configuration_editor_params
    params.require(:core_configuration_editor).permit(:account_id, :core_project_id, :name, :slug, :to_publish, :last_published_at, :content, :id, :marked_to_be_deleted)
  end
  
end