class MailingListsController < ApplicationController
  # Can't do anything unless signed in
  before_action :authenticate_user!

  # GET /mailing_lists
  # GET /mailing_lists.json
  def index
    @lists = MailingList.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lists }
    end
  end

  # GET /mailing_lists/1
  # GET /mailing_lists/1.json
  def show
    @list = MailingList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @list }
    end
  end

  # GET /mailing_lists/new
  # GET /mailing_lists/new.json
  def new
    @list = MailingList.new
    @query_present = false

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @list }
    end
  end

  # GET /mailing_lists/1/edit
  def edit
    @list = MailingList.find(params[:id])
    @search = Member.ransack(@list.query)
    @query_present = @list.query.present?
  end

  # POST /mailing_lists
  # POST /mailing_lists.json
  def create
    params[:mailing_list].delete(:query) if params[:suppress_query_form]
    @list = MailingList.new(mailing_list_params)

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, notice: 'Mailing List was successfully created.' }
        format.json { render json: @list, status: :created, location: @list }
      else
        format.html { render action: :new }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mailing_lists/1
  # PUT /mailing_lists/1.json
  def update
    params[:mailing_list][:query] = {} if params[:suppress_query_form]
    @list = MailingList.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(mailing_list_params)
        format.html { redirect_to @list, notice: 'Mailing List was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mailing_lists/1
  # DELETE /mailing_lists/1.json
  def destroy
    @list = MailingList.find(params[:id])
    @list.destroy

    respond_to do |format|
      format.html { redirect_to mailing_lists_url }
      format.json { head :no_content }
    end
  end

  private

  def mailing_list_params
    params.require(:mailing_list).permit(:name, member_ids: [], query: {}).tap do |whitelisted|
      whitelisted[:query] = params[:mailing_list][:query].permit! if params[:mailing_list].key? :query
    end
  end
end
