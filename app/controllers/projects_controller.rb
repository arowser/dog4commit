require 'net/http'

class ProjectsController < ApplicationController
  def index
    @projects = Project.order(available_amount_cache: :desc, watchers_count: :desc, full_name: :asc).page(params[:page]).per(30)
  end

  def show
    @project = Project.find params[:id]
    if @project and @project.bitcoin_address.nil? and (github_id = @project.github_id).present?
      label = "#{github_id}@dog4commit"
      address = DogecoinDaemon.instance.get_new_address(label)
      @project.update_attributes(bitcoin_address: address, address_label: label)
    end
  end

  def qrcode
    @project = Project.find params[:id]
    respond_to do |format|
      format.svg  { render :qrcode => @project.bitcoin_address, level: :l, unit: 4 }
    end
  end

  def create
    project_name = params[:full_name].
      gsub(/https?\:\/\/github.com\//, '').
      gsub(/\#.+$/, '').
      gsub(' ', '')
    client = Octokit::Client.new \
      :client_id     => CONFIG['github']['key'],
      :client_secret => CONFIG['github']['secret']
    begin
      repo = client.repo project_name
      @project = Project.find_or_create_by full_name: repo.full_name
      @project.update_github_info repo
      redirect_to @project
    rescue Octokit::NotFound
      redirect_to projects_path, alert: "Project not found"
    end
  end
end
