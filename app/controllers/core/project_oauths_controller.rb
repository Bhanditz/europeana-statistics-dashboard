class Core::ProjectOauthsController < ApplicationController

  before_action :sudo_project_member!
  before_action :set_project, except: [:callback, :refresh_token]
  
  def index
    @enable_express_tour = true
    @core_project_oauths = @core_project.core_project_oauths
  end

  def create_sessions
    provider = params[:provider]
    session[:oauth_project] = {account_id: params[:account_id], project_id: params[:project_id], provider: provider}
    redirect_to "/auth/#{provider}"
  end

  def callback
    if session[:oauth_project]
      account_id = session[:oauth_project][:account_id]
      project_id = session[:oauth_project][:project_id]
      provider   = session[:oauth_project][:provider]
      properties = request.env['omniauth.auth']
      unique_id  = request.env['omniauth.auth'].uid
      oauth_data = Core::ProjectOauth.find_by_unique_id(unique_id)
      if oauth_data.nil?
        proj_id = Core::Project.find_by_slug(project_id).id
        Core::ProjectOauth.create(core_project_id: proj_id, unique_id: unique_id, provider: provider, properties: properties)
      else 
        oauth_data.properties = properties
        oauth_data.save!
      end
      session.delete(:oauth_project)
      redirect_to oauth_account_core_project_path(account_id, project_id), notice: "Oauth Added" 
    else
       redirect_to root_url, alert: "Opps something goes wrong."
    end
  end

  def refresh_token
    unique_id    = params[:unique_id]
    core_project = Core::ProjectOauth.find_by_unique_id(unique_id)
    project_id   = params[:project_id]
    if core_project.nil?
      redirect_to oauth_account_core_project_path(current_account, project_id), alert: "oops something went wrong" 
      return false
    else      
      properties           = core_project.properties
      google_refresh_token = properties["credentials"]["token"]
      google_token_expire  = Time.at(properties["credentials"]["expires_at"])
      if google_token_expire < Time.now
        credentials = {:client_id => GOOGLE_CLIENT_ID, :grant_type => "refresh_token",
          :client_secret => GOOGLE_CLIENT_SECRET, :refresh_token => google_refresh_token }
        response = ActiveSupport::JSON.decode(RestClient.post "https://accounts.google.com/o/oauth2/token", credentials)
        if response["access_token"].present?
          core_project.properties["credentials"]["token"] = response["access_token"]
          core_project.save!
          return true
        end
      end
    end
    redirect_to oauth_account_core_project_path(current_account, project_id), notice: "Oauth Added" 
  end

  def destroy     
    core_project = Core::ProjectOauth.find(params[:oauth_id])
    core_project.destroy
    redirect_to oauth_account_core_project_path(current_account, params[:project_id]), alert: "Oauth Deleted"     
  end

  #------------------------------------------------------------------------------------------------------------------

  private
  
  def set_project
    @core_project = @account.core_projects.friendly.find(params[:id].blank? ? params[:project_id] : params[:id])
  end

  def core_project_params
    params.require(:core_project_oauths).permit(:core_project_id, :unique_id, :provider, 
                   :properties, :created_by, :updated_by) #hstore - properties
  end

end
