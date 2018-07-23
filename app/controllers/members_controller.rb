class MembersController < ApplicationController
  # Can't do anything unless signed in
  before_filter :authenticate_user!

  before_action :set_member, only: %i[show edit update toggle_paid destroy]

  # GET /members
  # GET /members.json
  def index
    @members = Member.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @members }
    end
  end

  # GET /members/1
  # GET /members/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @member }
    end
  end

  # GET /members/new
  # GET /members/new.json
  def new
    @member = Member.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @member }
    end
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render json: @member, status: :created, location: @member }
      else
        format.html { render action: :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update_attributes(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def toggle_paid
    case params[:fee]
    when 'subs'
      @member.subs_paid = !@member.subs_paid
    when 'show'
      @member.show_fee_paid = !@member.show_fee_paid
    when 'concert'
      @member.concert_fee_paid = !@member.concert_fee_paid
    end
    @member.save!

    @toggled_id = "#{params[:fee]}-#{params[:id]}"
    respond_to do |format|
      format.html { redirect_to action: :index }
      format.js
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy

    respond_to do |format|
      format.html { redirect_to members_url }
      format.json { head :no_content }
    end
  end

  private

  def set_member
    @member = Member.friendly.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:addr1,
                                   :addr2,
                                   :addr3,
                                   :concert_fee_paid,
                                   :county,
                                   :email,
                                   :forename,
                                   :membership,
                                   :mobile,
                                   :phone,
                                   :postcode,
                                   :show_fee_paid,
                                   :subs_paid,
                                   :surname,
                                   :town,
                                   :voice,
                                   :notes,
                                   :join_year,
                                   mailing_list_ids: [])
  end
end
