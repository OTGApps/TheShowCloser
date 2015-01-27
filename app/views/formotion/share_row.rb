module Formotion
  module RowType
    class ShareRow < ActivityRow

      def on_select(tableView, tableViewDelegate)
        super
        AppLogger.log("SHARE_TAPPED")
      end

    end
  end
end
