class ReceiptScreen < PM::WebScreen
  title "Receipt"
  tab_bar_item icon: "receipt", title: "Receipt"

  KHTMLCheckboxChecked = "&#x2611;"
  KHTMLCheckboxUnchecked = "&#x2610;"

  def content
    parsed_html
  end

  def jewelry_template(item = "&nbsp;", qty = "&nbsp;", name = "&nbsp;", price = "&nbsp;", total = "&nbsp;")
    "<tr>
      <td>#{item}</td>
      <td>#{qty}</td>
      <td>#{name}</td>
      <td class='ral'>$#{price}</td>
      <td class='ral strong'>$#{total}</td>
    </tr>"
  end

  def on_init
    super
    web.scalesPageToFit = true
	  web.dataDetectorTypes = UIDataDetectorTypeNone
  end

  def on_load
    view.backgroundColor = UIColor.whiteColor
    set_nav_bar_button :right, {
      title: "Email Receipt",
      system_item: :reply,
      action: :email_receipt
    }
  end

  def on_appear
    set_content(parsed_html)
  end

  def email_receipt
    BW::Mail.compose(
      delegate: self,
      html: true,
      subject: " Premier Designs Receipt from #{App::Persistence['kReceiptName']}",
      message: html,
    ) do |result, error|
      # result.sent?      # => boolean
      # result.canceled?  # => boolean
      # result.saved?     # => boolean
      # result.failed?    # => boolean
      # error             # => NSError
    end

  end

  def parsed_html
    ap "Getting parsed HTML"
    html = File.read(File.join(App.resources_path, "ReceiptTemplate.html"))
    ch = Hostesses.shared_hostess.current_hostess

    # We don't have a current hostess yet!
    return html if ch.nil?

    ap "Setting html contents"

    brain = Brain.new
    report_data = brain.to_dict

    html.sub!('[[[DATE]]]', Time.now.full_date) # Put the date on the receipt
    html.sub!('[[[SHOW_DATE]]]', ch.createdDate.full_date)
    html.sub!('[[[HOSTESS_NAME]]]', ch.name)
    html.sub!('[[[JEWELER_NAME]]]', App::Persistence['kReceiptName'])

    # Put the tax rate on the receipt
    html.sub!('[[[TAX_RATE]]]', ch.tax_rate.to_s)
	   # Put the shipping rate on the receipt
    html.sub!('[[[SHIPPING_RATE]]]', ch.shipping_rate.to_s)

    # Hostess half Price selections
    half_price_html = ''
    if ch.halfprice_items.count > 0
      ap "#{ch.halfprice_items.count} half price items."

      ch.halfprice_items.each do |item|
        half_price_html << jewelry_template(item.item, item.qtyHalfPrice, item.name || '', BigDecimal.new(item.price), BigDecimal.new(item.price) / 2)
      end
    else
      ap "No half price items."
      half_price_html << jewelry_template
    end

    html.sub!('[[[HALF_PRICE_SELECTIONS]]]', half_price_html)
    html.sub!('[[[HALF_PRICE_TOTAL]]]', brain.half_price_total.to_s)

	  # Bonuses
    bonuses_total = 0
    is_catalog_show = (brain.jewelry_percentage == 20) ? true : false

    unless is_catalog_show
      bonus_count = 1
      [ch.bonus1, ch.bonus2, ch.bonus3, ch.bonus4].each do |bonus|
        next if ch.new_hostess_plan? && bonus_count > 2
        if bonus == true
          html.sub!("[[[BONUS_#{bonus_count}]]]", KHTMLCheckboxChecked)
        else
          html.sub!("[[[BONUS_#{bonus_count}]]]", KHTMLCheckboxUnchecked)
        end
        bonus_count = bonus_count + 1
      end
    end

    # Half Price selections
    free_html = ''
    if ch.free_items.count > 0
      ch.free_items.each do |item|
        free_html << jewelry_template(item.item, item.qtyFree, item.name || '', BigDecimal.new(item.price), BigDecimal.new(item.price) / 2)
      end
    else
      free_html << jewelry_template
    end

    html.sub!('[[[BENEFIT_SELECTIONS]]]', free_html)
    html.sub!('[[[BENEFIT_TOTAL]]]', dolarize(brain.free_total))
    html.sub!('[[[AWARD_COUNT]]]', bonus_count.to_i.to_s)

    # Bonus values
    bonus_html = dolarize(report_data['awardValueTotal5'])
    bonus_html << " (+#{dolarize(h.bonusExtra)})" if h.bonusExtra > 0
    html.sub!('[[[AWARD_VALUE_TOTAL]]]', bonus_html)

    html.sub!('[[[AWARD_VALUE]]]', dolarize(h.bonusValue))

	# template = [template stringByReplacingOccurrencesOfString:@"[[[TOTAL_RETAIL]]]" withString:[NSString stringWithFormat:@"$%@", [jb totalRetail]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[RETAIL_PLUS_HALF]]]" withString:[NSString stringWithFormat:@"$%@", [report_data objectForKey:@"retailPlusHalf"]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[JEWELRY_PERCENTAGE]]]" withString:[NSString stringWithFormat:@"%u", [[report_data objectForKey:@"jewelryPercentage"] intValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[EQUALS_FOUR]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"equalsFour"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[TOTAL_HOSTESS_BENEFITS]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"totalHostessBenefitsSix"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[SUBTOTAL_ONE_ABC]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"subtotalOneABC"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[TAX_AMOUNT]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"taxTotal"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[SUBTOTAL_TWO]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"subtotalTwo"] floatValue]]];

	# if([[report_data objectForKey:@"totalHostessBenefitsSix"] floatValue] < [[jb free_total] floatValue])
	# {
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[WHICHEVER_IS_LESS]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"totalHostessBenefitsSix"] floatValue]]];
	# }
	# else
	# {
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[WHICHEVER_IS_LESS]]]" withString:[NSString stringWithFormat:@"$%.2f", [[jb free_total] floatValue]]];
	# }

	# //Discount
 #    NSString *specialDiscountString = @"</tr><tr><th style=\"font-weight: normal;text-align: right\">Discount:</th>"
 #    "<th style=\"font-weight: normal;text-align: right\">-</th>"
 #    "<td style=\"border: none;text-align: right;border-bottom: 1px solid #CCC\">$%.2f</td>";
 #    if([[report_data objectForKey:@"finalDiscount"] floatValue] > 0)
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_DISCOUNT]]]" withString:[NSString stringWithFormat:specialDiscountString, [[report_data objectForKey:@"finalDiscount"] floatValue]]];
 #    else
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_DISCOUNT]]]" withString:@""];

	# //Charge
 #    NSString *specialChargeString = @"</tr><tr><th style=\"font-weight: normal;text-align: right\">Charge:</th>"
 #    "<th style=\"font-weight: normal;text-align: right\">+</th>"
 #    "<td style=\"border: none;text-align: right;border-bottom: 1px solid #CCC\">$%.2f</td>";
 #    if([[report_data objectForKey:@"finalCharge"] floatValue] > 0)
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_CHARGE]]]" withString:[NSString stringWithFormat:specialChargeString, [[report_data objectForKey:@"finalCharge"] floatValue]]];
 #    else
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_CHARGE]]]" withString:@""];

 #    //Total
 #    template = [template stringByReplacingOccurrencesOfString:@"[[[TOTAL_DUE]]]" withString:[NSString stringWithFormat:@"$%.2f", [[report_data objectForKey:@"totalDue"] floatValue]]];

	# self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"Total: $%.2f", [[report_data objectForKey:@"totalDue"] floatValue]];

    html
  end

  def dolarize(number)
    "$#{number}"
  end

end
