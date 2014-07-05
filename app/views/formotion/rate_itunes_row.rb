module Formotion
  module RowType
    class RateItunesRow < WebLinkRow

      def on_select(tableView, tableViewDelegate)
        Appirater.rateApp
        Flurry.logEvent("PRESSED_RATE_APP") unless Device.simulator?
      end

    end
  end
end
