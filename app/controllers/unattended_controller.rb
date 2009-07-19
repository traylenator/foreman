class UnattendedController < ApplicationController
  before_filter :get_host_details

  def kickstart
    render :text => "Kickstart" if @host
  end

  def jumpstart
  end

  def preseed
  end

  private
  def get_host_details
    # find out ip info
    if params.has_key? "spoof"
      ip = params.delete("spoof")
    elsif (ip = request.env['REMOTE_ADDR']) =~ /127.0.0/
      ip = request.env["HTTP_X_FORWARDED_FOR"] unless request.env["HTTP_X_FORWARDED_FOR"].nil?
    end

    unless request.env['HTTP_X_RHN_PROVISIONING_MAC_0'].nil?
      mac=request.env['HTTP_X_RHN_PROVISIONING_MAC_0'].split[1].downcase.strip
    end

    conditions = (mac and ip) ? ["mac = ? and ip = ?",mac, ip] : ["ip = ?",ip];
    @host = Host.find(:first, :include => [:architecture, :media, :os, :domain], :conditions => conditions)
    if @host.nil?
      logger.info "#{controller_name}: unable to find #{ip}#{(" "+mac) unless mac.nil?}"
      head(:not_found) if @host.nil? and return
    else
      logger.info "#{controller_name}: Kickstart host #{@host.name}"
    end
  end

end