class NSDate
  def short_date
    dateFormatter = NSDateFormatter.alloc.init
    dateFormatter.setTimeStyle(NSDateFormatterNoStyle)
    dateFormatter.setDateStyle(NSDateFormatterMediumStyle)
    dateFormatter.stringFromDate(self)
  end
end
