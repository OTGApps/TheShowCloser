module Formotion
  module RowType
    class RateItunesRow < WebLinkRow

      def on_select(tableView, tableViewDelegate)
        Appirater.rateApp
        AppLogger.log("PRESSED_RATE_APP")
      end

    end
  end
end
