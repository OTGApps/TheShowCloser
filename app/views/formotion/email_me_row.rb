module Formotion
  module RowType
    class EmailMeRow < ObjectRow

      def after_build(cell)
        super
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
        self.row.text_field.hidden = true
      end

      def on_select(tableView, tableViewDelegate)
        BW::Mail.compose({
          delegate: row.form.controller,
          to: row.value[:to],
          subject: row.value[:subject],
          message: row.value[:message] || "",
          animated: true
        }) do |result, error|
          AppLogger.log("EMAIL_SENT") if result.sent?
          AppLogger.log("EMAIL_CANCELED") if result.canceled?
          AppLogger.log("EMAIL_FAILED") if result.failed?
        end
      end

    end
  end
end
