class InboundParseController < ApplicationController

  def parse
    Rails.logger.info("Parsing the following:")
    Rails.logger.info(params)

    render text: "Received: #{params}"
  end

end
