class UIImage

  # Derived from:
  # http://isujith.wordpress.com/2010/09/09/uiimage-with-given-text-and-size/
  def self.cellImageWithText(text)
    size = CGSizeMake(80, 80)
    text = text.to_s unless text.is_a?(String)

    # Create a bitmap graphics context of the given size
    colorSpace = CGColorSpaceCreateDeviceRGB()
    context = CGBitmapContextCreate(nil, size.width, size.height, 8, size.width*4, colorSpace, KCGImageAlphaPremultipliedLast)

    return nil if context.nil?

    # Custom CGContext coordinate system is flipped with respect to UIView, so transform, then push
    CGContextTranslateCTM(context, 0, size.height)
    CGContextScaleCTM(context, 1.0, -1.0)
    UIGraphicsPushContext(context)

    # Inset the text rect then draw the text
    textRect = CGRectMake(4, 4, size.width - 8, size.height - 8)
    font = UIFont.boldSystemFontOfSize(60)
    UIColor.blackColor.set
    text.drawInRect(textRect, withFont:font, lineBreakMode:UILineBreakModeTailTruncation, alignment:UITextAlignmentCenter)

    # Create and return the UIImage object
    cgImage = CGBitmapContextCreateImage(context)
    uiImage = UIImage.alloc.initWithCGImage(cgImage)
    UIGraphicsPopContext();

    uiImage
  end
end
