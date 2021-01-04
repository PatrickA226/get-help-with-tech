require 'nokogiri'

class Computacenter::OutgoingAPI::CapUpdateRequest
  attr_accessor :endpoint, :username, :password, :allocation_ids, :timestamp
  attr_accessor :body, :payload_id, :response, :logger

  def initialize(args = {})
    @endpoint       = args[:endpoint] || setting(:endpoint)
    @username       = args[:username] || setting(:username)
    @password       = args[:password] || setting(:password)
    @timestamp      = args[:timestamp] || Time.zone.now
    @payload_id     = args[:payload_id]
    @allocation_ids = args[:allocation_ids]
    @logger         = args[:logger] || Rails.logger
  end

  def post!
    # Need to regenerate this for every request, but still allow for
    # overrides when testing
    @payload_id ||= SecureRandom.uuid
    @body = construct_body

    @logger.info("POSTing to Computacenter, payload_id: #{@payload_id}, body: \n#{@body}")
    @response = HTTP.basic_auth(user: @username, pass: @password)
                    .post(@endpoint, body: @body)
    handle_response!
  end

  def handle_response!
    response_body = @response.body.to_s
    @logger.info("Response from Computacenter: \n#{response_body}")
    unless success?
      raise(
        Computacenter::OutgoingAPI::Error.new(cap_update_request: self),
        "Computacenter responded with #{@response.status}, response_body: #{response_body}",
      )
    end

    @response
  end

  def setting(name)
    Settings.computacenter.outgoing_api.send(name)
  end

  def construct_body
    allocations = get_allocation_data
    renderer.render :cap_update_request, format: :xml, assigns: { allocations: allocations, payload_id: @payload_id, timestamp: @timestamp }
  end

  def renderer
    Computacenter::OutgoingAPI::BaseController
  end

private

  def get_allocation_data
    records = SchoolDeviceAllocation.includes(school: :preorder_information).where(id: @allocation_ids)

    if records.present?
      responsible_body = records.first.school.responsible_body

      zero_caps = responsible_body.has_multiple_chromebook_domains_in_managed_schools?

      records = records.map do |allocation|
        # It's possible that a devolved school will be within a responsible body that is centrally managing,
        # in which case it's not necessary to adjust the cap down to force it into the manual queue.
        cap = if zero_caps && allocation.school&.preorder_information&.responsible_body_will_order_devices?
                allocation.raw_devices_ordered
              else
                allocation.computacenter_cap
              end
        OpenStruct.new(cap_type: allocation.computacenter_cap_type,
                       ship_to: allocation.school.computacenter_reference,
                       cap: cap)
      end
    end

    records
  end

  def success?
    @response.status.success? && xml_success?
  end

  def xml_response
    @xml_response ||= Nokogiri::XML(@response.body)
  end

  def xml_success?
    return true if xml_response.css('HeaderResult').blank?

    xml_response.css('HeaderResult').attr('status').value == 'Success'
  end
end
