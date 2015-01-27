module Formotion
  module RowType
    class IssueLinkRow < WebLinkRow

      def on_select(tableView, tableViewDelegate)
        super
        AppLogger.log("GITHUB_ISSUE_TAPPED")
      end

    end
  end
end
