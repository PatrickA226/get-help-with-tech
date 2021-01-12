class SupportTicket::CollegeDetailsController < SupportTicket::BaseController
  def new
    @form ||= SupportTicket::CollegeDetailsForm.new(set_params)
    render 'support_tickets/college_details'
  end

  def save
    if form.valid?
      session[:support_ticket].merge!({
        college_name: form.college_name,
        college_ukprn: form.college_ukprn,
        school_name: form.college_name,
        school_unique_id: form.college_ukprn,
      })
      redirect_to next_step
    else
      render 'support_tickets/college_details'
    end
  end

private

  def form
    @form ||= SupportTicket::CollegeDetailsForm.new(college_details_params)
  end

  def college_details_params(opts = params)
    opts.fetch(:support_ticket_college_details_form, {}).permit(:college_name, :college_ukprn)
  end

  def set_params
    if session[:support_ticket].present? && session[:support_ticket]['college_name'].present?
      {
        college_name: session[:support_ticket]['college_name'],
        college_ukprn: session[:support_ticket]['college_ukprn'],
      }
    else
      { college_name: nil, college_ukprn: nil }
    end
  end

  def next_step
    support_ticket_contact_details_path
  end
end