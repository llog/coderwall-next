class JobsController < ApplicationController

  def index
    @jobs = Job.active.order(created_at: :desc)
    if params[:posted]
      @jobs = @jobs.where.not(id: params[:posted])
      @featured = Job.find(params[:posted])
    end
  end

  def new
    @job = Job.new
  end

  def show
    redirect_to Job.find(params[:id]).source
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      redirect_to review_job_path(@job)
    else
      render action: 'new'
    end
  end

  def review
    @job = Job.find(params[:id])
  end

  def publish
    @job = Job.find(params[:job_id])
    @job.charge!(params['stripeToken'])

    flash[:notice] = "Your job is now live"
    redirect_to jobs_path(posted: @job.id)

  rescue Stripe::CardError => e
    flash[:notice] = e.message
    redirect_to review_job_path(@job)
  end

  # private

  def job_params
    params.require(:job).permit(:source)
  end

end