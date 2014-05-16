class ReceiptScreen < PM::WebScreen
  title "Receipt"
  tab_bar_item icon: "receipt", title: "Receipt"

  def content
    parsed_html
  end

  def on_init
    super
    web.scalesPageToFit = true
	  web.dataDetectorTypes = UIDataDetectorTypeNone
  end

  def on_load
    view.backgroundColor = UIColor.whiteColor
  end

  def parsed_html
    html = File.read(File.join(App.resources_path, "ReceiptTemplate.html"))
    h = Hostesses.shared_hostess.current_hostess

	# jb.jbJewelry = [h getWishList];
	# NSDictionary *reportData = [jb totalDict];

    html.sub! '[[[DATE]]]', Time.now.full_date # Put the date on the receipt
    # html.sub! '[[[SHOW_DATE]]]', h.showDate.full_date
    # html.sub! '[[[HOSTESS_NAME]]]', h.name
    # html.sub! '[[[JEWELER_NAME]]]', h.name


	# //Put the tax rate on the receipt
	# template = [template stringByReplacingOccurrencesOfString:@"[[[TAX_RATE]]]" withString:[NSString stringWithFormat:@"%@%%", [jb getTaxRate]]];
	# //Put the shipping rate on the receipt
	# template = [template stringByReplacingOccurrencesOfString:@"[[[SHIPPING_RATE]]]" withString:[NSString stringWithFormat:@"$%@", [jb getShippingRate]]];

	# //Get out yer half price stuffs!
	# NSMutableString *halfPriceHTML = [[NSMutableString alloc] init];
	# int halfPriceTotal = 0;
	# for (Jewelry *j in [h getWishListHalf])
	# {
	# 	[halfPriceHTML appendString:[NSString stringWithFormat:kReceiptJewelryHTMLTemplate, [j.item stringValue], [j getQtyForJewelerySatus:kHalfPrice], j.name, [NSNumber numberWithFloat:[j.price floatValue]], [NSNumber numberWithFloat:[[j getQtyForJewelerySatus:kHalfPrice] intValue] * ([j.price floatValue] / 2)]]];
	# 	halfPriceTotal++;
	# }
	# if(halfPriceTotal == 0)
	# {
	# 	[halfPriceHTML appendString:[NSString stringWithFormat:kReceiptJewelryHTMLTemplate, @"&nbsp;", @"&nbsp;", @"&nbsp;", @"&nbsp;", @"&nbsp;"]];
	# }

	# template = [template stringByReplacingOccurrencesOfString:@"[[[HALF_PRICE_SELECTIONS]]]" withString:halfPriceHTML];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[HALF_PRICE_TOTAL]]]" withString:[NSString stringWithFormat:@"$%@", [jb halfPriceTotal]]];

	# //Bonuses
	# int bonusTotal = 0;
	# bool isCatalogShow = NO;
 #    if([jb jewelryPercentage] == 20)isCatalogShow = YES;

 #    BOOL isNewBonusStructure = [h shouldUseNewHostessPlan];

	# if([h.bonus1 boolValue] == YES && isCatalogShow == NO)
	# {
 #        if (isNewBonusStructure)
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_1]]]" withString:kHTMLCheckboxChecked];
 #        else
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_ORIG_DATE]]]" withString:kHTMLCheckboxChecked];

	# 	bonusTotal++;
	# }
	# else
	# {
 #        if (isNewBonusStructure)
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_1]]]" withString:kHTMLCheckboxUnchecked];
 #        else
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_ORIG_DATE]]]" withString:kHTMLCheckboxUnchecked];
	# }

	# if([h.bonus2 boolValue] == YES && isCatalogShow == NO)
	# {
 #        if (isNewBonusStructure)
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_2]]]" withString:kHTMLCheckboxChecked];
 #        else
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_TEN_GUESTS]]]" withString:kHTMLCheckboxChecked];

	# 	bonusTotal++;
	# }
	# else
	# {
 #        if (isNewBonusStructure)
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_2]]]" withString:kHTMLCheckboxUnchecked];
 #        else
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_TEN_GUESTS]]]" withString:kHTMLCheckboxUnchecked];
	# }

 #    /* Legacy Support */
 #    if (isNewBonusStructure == NO)
 #    {
 #        if([h.bonus3 boolValue] == YES && isCatalogShow == NO)
 #        {
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_ADVANCE_ORDERS]]]" withString:kHTMLCheckboxChecked];
 #            bonusTotal++;
 #        }
 #        else
 #        {
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_ADVANCE_ORDERS]]]" withString:kHTMLCheckboxUnchecked];
 #        }

 #        if([h.bonus4 boolValue] == YES && isCatalogShow == NO)
 #        {
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_BOOKINGS]]]" withString:kHTMLCheckboxChecked];
 #            bonusTotal++;
 #        }
 #        else
 #        {
 #            template = [template stringByReplacingOccurrencesOfString:@"[[[BONUS_BOOKINGS]]]" withString:kHTMLCheckboxUnchecked];
 #        }
 #    }
 #    /* End Lagacy Support */

	# //Get out yer half price stuffs!
	# NSMutableString *freeHTML = [[NSMutableString alloc] init];
	# int freeTotal = 0;
	# for (Jewelry *j in [h getWishListFree])
	# {
	# 	[freeHTML appendString:[NSString stringWithFormat:kReceiptJewelryHTMLTemplate, [j.item stringValue], [j getQtyForJewelerySatus:kFree], j.name, j.price, [NSNumber numberWithFloat:([[j getQtyForJewelerySatus:kFree] intValue] * [j.price floatValue])]]];
	# 	freeTotal++;
	# }
	# if(freeTotal == 0)
	# {
	# 	[freeHTML appendString:[NSString stringWithFormat:kReceiptJewelryHTMLTemplate, @"&nbsp;", @"&nbsp;", @"&nbsp;", @"&nbsp;", @"&nbsp;"]];
	# }

	# template = [template stringByReplacingOccurrencesOfString:@"[[[BENEFIT_SELECTIONS]]]" withString:freeHTML];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[BENEFIT_TOTAL]]]" withString:[NSString stringWithFormat:@"$%@", [jb freeTotal]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[AWARD_COUNT]]]" withString:[NSString stringWithFormat:@"%u", bonusTotal]];

 #    // Bonus values
 #    if([h.bonusExtra floatValue] > 0){
 #        template = [template stringByReplacingOccurrencesOfString:@"[[[AWARD_VALUE_TOTAL]]]" withString:[NSString stringWithFormat:@"$%@ (+$%@)", [reportData objectForKey:@"awardValueTotal5"], h.bonusExtra]];
 #    }else{
 #        template = [template stringByReplacingOccurrencesOfString:@"[[[AWARD_VALUE_TOTAL]]]" withString:[NSString stringWithFormat:@"$%@", [reportData objectForKey:@"awardValueTotal5"]]];
 #    }

 #    template = [template stringByReplacingOccurrencesOfString:@"[[[AWARD_VALUE]]]" withString:[NSString stringWithFormat:@"$%@", h.bonusValue]];

	# template = [template stringByReplacingOccurrencesOfString:@"[[[TOTAL_RETAIL]]]" withString:[NSString stringWithFormat:@"$%@", [jb totalRetail]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[RETAIL_PLUS_HALF]]]" withString:[NSString stringWithFormat:@"$%@", [reportData objectForKey:@"retailPlusHalf"]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[JEWELRY_PERCENTAGE]]]" withString:[NSString stringWithFormat:@"%u", [[reportData objectForKey:@"jewelryPercentage"] intValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[EQUALS_FOUR]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"equalsFour"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[TOTAL_HOSTESS_BENEFITS]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"totalHostessBenefitsSix"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[SUBTOTAL_ONE_ABC]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"subtotalOneABC"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[TAX_AMOUNT]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"taxTotal"] floatValue]]];
	# template = [template stringByReplacingOccurrencesOfString:@"[[[SUBTOTAL_TWO]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"subtotalTwo"] floatValue]]];

	# if([[reportData objectForKey:@"totalHostessBenefitsSix"] floatValue] < [[jb freeTotal] floatValue])
	# {
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[WHICHEVER_IS_LESS]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"totalHostessBenefitsSix"] floatValue]]];
	# }
	# else
	# {
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[WHICHEVER_IS_LESS]]]" withString:[NSString stringWithFormat:@"$%.2f", [[jb freeTotal] floatValue]]];
	# }

	# //Discount
 #    NSString *specialDiscountString = @"</tr><tr><th style=\"font-weight: normal;text-align: right\">Discount:</th>"
 #    "<th style=\"font-weight: normal;text-align: right\">-</th>"
 #    "<td style=\"border: none;text-align: right;border-bottom: 1px solid #CCC\">$%.2f</td>";
 #    if([[reportData objectForKey:@"finalDiscount"] floatValue] > 0)
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_DISCOUNT]]]" withString:[NSString stringWithFormat:specialDiscountString, [[reportData objectForKey:@"finalDiscount"] floatValue]]];
 #    else
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_DISCOUNT]]]" withString:@""];

	# //Charge
 #    NSString *specialChargeString = @"</tr><tr><th style=\"font-weight: normal;text-align: right\">Charge:</th>"
 #    "<th style=\"font-weight: normal;text-align: right\">+</th>"
 #    "<td style=\"border: none;text-align: right;border-bottom: 1px solid #CCC\">$%.2f</td>";
 #    if([[reportData objectForKey:@"finalCharge"] floatValue] > 0)
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_CHARGE]]]" withString:[NSString stringWithFormat:specialChargeString, [[reportData objectForKey:@"finalCharge"] floatValue]]];
 #    else
	# 	template = [template stringByReplacingOccurrencesOfString:@"[[[SPECIAL_CHARGE]]]" withString:@""];

 #    //Total
 #    template = [template stringByReplacingOccurrencesOfString:@"[[[TOTAL_DUE]]]" withString:[NSString stringWithFormat:@"$%.2f", [[reportData objectForKey:@"totalDue"] floatValue]]];

	# self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"Total: $%.2f", [[reportData objectForKey:@"totalDue"] floatValue]];

    html
  end

  # def on_appear
  #   ap "test"
  # end

end
