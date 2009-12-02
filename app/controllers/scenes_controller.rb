class ScenesController < ApplicationController
  # GET /scenes
  # GET /scenes.xml
  def index
    @scenes = Scene.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scenes }
    end
  end

  # GET /scenes/1
  # GET /scenes/1.xml
  def show
    @scene = Scene.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scene }
    end
  end

  # GET /scenes/new
  # GET /scenes/new.xml
  def new
    @scene = Scene.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scene }
    end
  end

  # GET /scenes/1/edit
  def edit
    @scene = Scene.find(params[:id])
  end

  # POST /scenes
  # POST /scenes.xml
  def create
    @scene = Scene.new(params[:scene])

    respond_to do |format|
      if @scene.save
        flash[:notice] = 'Scene was successfully created.'
        format.html { redirect_to(@scene) }
        format.xml  { render :xml => @scene, :status => :created, :location => @scene }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scenes/1
  # PUT /scenes/1.xml
  def update
    @scene = Scene.find(params[:id])

    respond_to do |format|
      if @scene.update_attributes(params[:scene])
        flash[:notice] = 'Scene was successfully updated.'
        format.html { redirect_to(@scene) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scenes/1
  # DELETE /scenes/1.xml
  def destroy
    @scene = Scene.find(params[:id])
    @scene.destroy

    respond_to do |format|
      format.html { redirect_to(scenes_url) }
      format.xml  { head :ok }
    end
  end
end
