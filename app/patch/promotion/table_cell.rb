module ProMotion
  module TableViewCellModule
    include Styling

    protected

    def set_image
      return unless data_cell[:image]
      cell_image = data_cell[:image]
      cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)
      self.imageView.image = cell_image
    end

  end
end
