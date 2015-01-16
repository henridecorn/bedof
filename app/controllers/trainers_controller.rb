class TrainersController < ApplicationController
  before_action :set_trainer, only: [:show, :edit, :update, :destroy, :skip]

  # GET /trainers
  # GET /trainers.json
  def index
    @trainers = Trainer.paginate(:page => params[:page]).order(email_dirigeant: :desc, crawled_for_email: :desc)
    respond_to do |format|
      format.html
      format.csv { send_data Trainer.all.to_csv}
    end
  end

  # GET /trainers/1
  # GET /trainers/1.json
  def show
  end

  # GET /trainers/new
  def new
    @trainer = Trainer.new
  end

  # GET /trainers/1/edit
  def edit
  end

  # POST /trainers
  # POST /trainers.json
  def create
    @trainer = Trainer.new(trainer_params)

    respond_to do |format|
      if @trainer.save
        format.html { redirect_to @trainer, notice: 'Trainer was successfully created.' }
        format.json { render :show, status: :created, location: @trainer }
      else
        format.html { render :new }
        format.json { render json: @trainer.errors, status: :unprocessable_entity }
      end
    end
  end

  def import_official
    Trainer.import_official(params[:file])
    redirect_to trainers_url, notice: "Liste importée."
  end

  def import_societe
    Trainer.import_societe(params[:file])
    redirect_to trainers_url, notice: "Societés importées."
  end

  def crawl_for_emails
    validated_emails_count = Trainer.crawl_for_emails(params[:crawls_number])
    redirect_to trainers_url, notice: validated_emails_count.to_s + " emails ajoutés sur " + params[:crawls_number].to_s
  end

  def search
    @trainer = Trainer.where(siren: params[:siren]).first
    redirect_to @trainer
  end

  def skip
    @trainer.crawled_for_email = true
    @trainer.save
    redirect_to root_path, notice: @trainer.siren + " a été sauté"
  end


  # PATCH/PUT /trainers/1
  # PATCH/PUT /trainers/1.json
  def update
    respond_to do |format|
      if @trainer.update(trainer_params)
        format.html { redirect_to @trainer, notice: 'Trainer was successfully updated.' }
        format.json { render :show, status: :ok, location: @trainer }
      else
        format.html { render :edit }
        format.json { render json: @trainer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trainers/1
  # DELETE /trainers/1.json
  def destroy
    @trainer.destroy
    respond_to do |format|
      format.html { redirect_to trainers_url, notice: 'Trainer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trainer
      @trainer = Trainer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trainer_params
      params.require(:trainer).permit(:siren, :sigle, :effectif, :adresse, :nom_dirigeant, :email_dirigeant, :crawled_for_email)
    end
end
