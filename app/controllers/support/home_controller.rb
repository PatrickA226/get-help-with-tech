class Support::HomeController < Support::BaseController
  before_action { authorize :support }

  def show; end

  def schools; end
end
