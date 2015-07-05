class Core::CardsController < ApplicationController

  before_action :sudo_project_member!
  before_action :set_core_card, only: [:show, :edit, :update, :destroy]

  # GET /core_cards
  # GET /core_cards.json
  def index
    @core_cards = @core_project.core_cards
  end

  # GET /core_cards/new
  def new
    @core_card = Core::Card.new
  end

  # GET /core_cards/1/edit
  def edit
  end

  # POST /core_cards
  # POST /core_cards.json
  def create
    @core_card = Core::Card.new(core_card_params)
    if @core_card.save
      redirect_to ccount_core_project_card_path(@account, @core_project, @core_card), notice: t("c.s")
    else
      render :new
    end
  end

  # PATCH/PUT /core_cards/1
  # PATCH/PUT /core_cards/1.json
  def update
    if @core_card.update(core_card_params)
      redirect_to account_core_project_cards_path(@account, @core_project), notice: t("u.s")
    else
      render :edit
    end
  end

  # DELETE /core_cards/1
  # DELETE /core_cards/1.json
  def destroy
    @core_card.destroy
    redirect_to account_core_project_cards_path(@account, @core_project), notice: t("d.s")    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_core_card
      @core_card = @core_project.core_cards.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def core_card_params
      params.require(:core_card).permit(:name, :is_public, :content, :properties, :core_card_layout_id, :core_project_id, :core_datacast_identifier)
    end
end
