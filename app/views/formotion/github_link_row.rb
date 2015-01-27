module Formotion
  module RowType
    class GithubLinkRow < WebLinkRow

      def on_select(tableView, tableViewDelegate)
        super
        AppLogger.log("GITHUB_TAPPED")
      end

    end
  end
end
