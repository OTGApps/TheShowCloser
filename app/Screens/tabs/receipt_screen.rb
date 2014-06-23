class ReceiptScreen < PM::WebScreen
  title "Total: "
  tab_bar_item icon: "receipt", title: "Receipt"

  def content
    parsed_html
  end

  def jewelry_template(item = "&nbsp;", qty = "&nbsp;", name = "&nbsp;", price = "&nbsp;", total = "&nbsp;")
    "<tr>
      <td>#{item}</td>
      <td>#{qty}</td>
      <td>#{name}</td>
      <td class='ral'>#{dolarize(price)}</td>
      <td class='ral strong'>#{dolarize(total)}</td>
    </tr>"
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
    ch = Hostesses.shared_hostess.current_hostess

    if ch.nil?
      # We don't have a current hostess yet!
      return File.read(File.join(App.resources_path, "ReceiptError.html"))
    end

    html = File.read(File.join(App.resources_path, "ReceiptTemplate.html"))

    ap "Setting html contents"

    brain = Brain.new
    report_data = brain.to_dict
    ap report_data

    html.sub!('[[[DATE]]]', Time.now.full_date) # Put the date on the receipt
    html.sub!('[[[SHOW_DATE]]]', ch.createdDate.full_date)
    html.sub!('[[[HOSTESS_NAME]]]', ch.name)
    html.sub!('[[[JEWELER_NAME]]]', App::Persistence['kReceiptName'])

    html.sub!('[[[TOTAL_RETAIL]]]', dolarize(ch.showTotal))

    # Put the tax & shipping rates on the receipt
    html.sub!('[[[TAX_RATE]]]', ch.tax_rate.to_s)
    html.sub!('[[[SHIPPING_RATE]]]', dolarize(ch.shipping_rate.to_s))

    # Hostess half Price selections
    half_price_html = ''
    if ch.halfprice_items.count > 0
      ap "#{ch.halfprice_items.count} half price items."

      ch.halfprice_items.each do |item|
        big_d_item = BigDecimal.new(item.price)
        half_price_html << jewelry_template(item.item, item.qtyHalfPrice, item.name || '', big_d_item, big_d_item / 2)
      end
    else
      ap "No half price items."
      half_price_html << jewelry_template
    end

    html.sub!('[[[HALF_PRICE_SELECTIONS]]]', half_price_html)
    ap "half price total: #{brain.half_price_total}"
    html.gsub!('[[[HALF_PRICE_TOTAL]]]', dolarize(brain.half_price_total.to_s))

	  # Bonuses
    bonuses_total, bonus_count = 0, 0
    is_catalog_show = (brain.jewelry_percentage == 20) ? true : false
    ap "Is catalog show? #{is_catalog_show}"

    unless is_catalog_show

      ap "New hostess plan? #{ch.new_hostess_plan?}"
      [ch.bonus1, ch.bonus2, ch.bonus3, ch.bonus4].each do |bonus|
        break if ch.new_hostess_plan? && bonus_count > 1

        bonus = bonus.to_bool
        ap "Bonus #{bonus_count}: #{bonus}"

        if bonus == true
          checkbox = "&#x2611;"
          bonuses_total = bonuses_total + 1
        else
          checkbox = "&#x2610;"
        end

        html.sub!("[[[BONUS_#{bonus_count + 1}]]]", checkbox)
        bonus_count = bonus_count + 1
      end
    end

    # Half Price selections
    free_html = ''
    if ch.free_items.count > 0
      ch.free_items.each do |item|
        big_d_item = BigDecimal.new(item.price)
        free_html << jewelry_template(item.item, item.qtyFree, item.name || '', big_d_item, big_d_item)
      end
    else
      free_html << jewelry_template
    end

    html.sub!('[[[BENEFIT_SELECTIONS]]]', free_html)
    html.sub!('[[[BENEFIT_TOTAL]]]', dolarize(brain.free_total))
    html.sub!('[[[AWARD_COUNT]]]', bonuses_total.to_s)

    # Bonus values
    bonus_html = dolarize(report_data[:awardValueTotal5])
    bonus_html << " (+#{dolarize(ch.bonusExtra)})" if ch.bonusExtra > 0
    html.sub!('[[[AWARD_VALUE_TOTAL]]]', bonus_html)

    html.sub!('[[[AWARD_VALUE]]]', dolarize(ch.bonusValue))
    html.sub!('[[[RETAIL_PLUS_HALF]]]', dolarize(report_data[:retailPlusHalf]))
    html.sub!('[[[JEWELRY_PERCENTAGE]]]', report_data[:jewelryPercentage].to_s)
    html.sub!('[[[EQUALS_FOUR]]]', dolarize(report_data[:equalsFour]))
    html.sub!('[[[TOTAL_HOSTESS_BENEFITS]]]', dolarize(report_data[:totalHostessBenefitsSix]))
    html.sub!('[[[SUBTOTAL_ONE_ABC]]]', dolarize(report_data[:subtotalOneABC]))
    html.sub!('[[[TAX_AMOUNT]]]', dolarize(report_data[:taxTotal]))
    html.sub!('[[[SUBTOTAL_TWO]]]', dolarize(report_data[:subtotalTwo]))

    if report_data[:totalHostessBenefitsSix] < brain.free_total
      html.sub!('[[[WHICHEVER_IS_LESS]]]', dolarize(report_data[:totalHostessBenefitsSix]))
    else
      html.sub!('[[[WHICHEVER_IS_LESS]]]', dolarize(brain.free_total))
    end

    # Additional Discounts & Charges
    html.sub!('[[[SPECIAL_DISCOUNT]]]', special_discount_string(report_data[:finalDiscount]))
    html.sub!('[[[SPECIAL_CHARGE]]]', special_charge_string(report_data[:finalCharge]))

    # Total
    html.sub!('[[[TOTAL_DUE]]]', dolarize(report_data[:totalDue]))

    self.navigationController.navigationBar.topItem.title = "Total: #{dolarize(report_data[:totalDue])}"

    html
  end

  def dolarize(number)
    return number if number.is_a?(String)
    d = sprintf("$%.2f", number)
    if d.end_with?('.00')
      d[0...-3]
    else
      d
    end
  end

  def special_discount_string(d)
    (d > 0) ? discount_charge_string('Discount', dolarize(d)) : ''
  end

  def special_charge_string(c)
    (c > 0) ? discount_charge_string('Charge', dolarize(c)) : ''
  end

  def discount_charge_string(d_or_c, value)
    "</tr>
     <tr>
       <th style='font-weight: normal;text-align: right'>#{d_or_c}:</th>
       <th style='font-weight: normal;text-align: right'>-</th>
       <td style='border: none;text-align: right;border-bottom: 1px solid #CCC'>#{value}</td>"
  end
end
