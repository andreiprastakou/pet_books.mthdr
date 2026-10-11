# frozen_string_literal: true

# What of a title and byline actually fits on a generated cover.
# Geometry matches $b-cover-sizes and the author band in cover_designs.scss.
# Keep in sync with engines/frontend/app/javascript/utils/coverCopy.js.
module CoverLayout
  TITLE_LENGTH_LONG = 25
  AUTHOR_MAX_LINES = 4
  MULTI_AUTHOR_MAX_LINES = 2
  AUTHOR_LINE_HEIGHT = 1.1
  TITLE_LINE_HEIGHT = 1.2
  AUTHOR_BAND_FUDGE = 2
  AUTHOR_GAP = 4
  AUTHOR_CHAR_EM = 0.62
  TITLE_CHAR_EM = 0.70
  OMISSION = '...'
  DEFAULT_SIZE = 'lg'
  SMALL_SEPARATOR = 8

  # width, height, and fonts are the cover-size presets. Only `small` uses the pamphlet metrics.
  SIZES = {
    'xs' => { width: 100, height: 150, padding: 6, small_padding: 26, author_font: 8, title_font_long: 11,
              small_text_font: 9 },
    'sm' => { width: 120, height: 180, padding: 8, small_padding: 32, author_font: 9, title_font_long: 12,
              small_text_font: 10 },
    'md' => { width: 140, height: 210, padding: 9, small_padding: 38, author_font: 9, title_font_long: 14,
              small_text_font: 11 },
    'lg' => { width: 160, height: 240, padding: 10, small_padding: 45, author_font: 10, title_font_long: 16,
              small_text_font: 12 }
  }.freeze

  module_function

  def title(text, format: Book::FORMAT_NORMAL, size: DEFAULT_SIZE)
    text = text.to_s
    max = title_max_chars(format, size)
    return text if text.length <= max

    truncate(text, max)
  end

  # One author is always returned. Several names are returned only when they fit
  # on two lines; otherwise the cover stays untitled by them.
  # `tight` asks for the smaller byline face so one long name stays inside the band.
  def author_line(names, format: Book::FORMAT_NORMAL, size: DEFAULT_SIZE)
    cleaned = Array(names).map { |name| name.to_s.strip }.reject(&:empty?)
    return nil if cleaned.empty?

    text = cleaned.join(', ')
    per_line = author_chars_per_line(format, size)
    return { text:, tight: text.length > per_line * AUTHOR_MAX_LINES } if cleaned.one?
    return nil if text.length > per_line * MULTI_AUTHOR_MAX_LINES

    { text:, tight: false }
  end

  def title_max_chars(format, size = DEFAULT_SIZE)
    metrics = SIZES.fetch(size.to_s)
    small = format.to_s == Book::FORMAT_SMALL
    font = small ? metrics[:small_text_font] : metrics[:title_font_long]
    lines = title_lines(metrics, small:, font:)
    lines * chars_per_line(text_width(metrics, small:), font, TITLE_CHAR_EM)
  end

  def author_chars_per_line(format, size = DEFAULT_SIZE)
    metrics = SIZES.fetch(size.to_s)
    small = format.to_s == Book::FORMAT_SMALL
    font = small ? metrics[:small_text_font] : metrics[:author_font]
    chars_per_line(text_width(metrics, small:), font, AUTHOR_CHAR_EM)
  end

  def title_lines(metrics, small:, font:)
    text_height = small ? small_title_height(metrics) : standard_title_height(metrics)
    [(text_height / (font * TITLE_LINE_HEIGHT)).floor, 1].max
  end

  def standard_title_height(metrics)
    inner = metrics[:height] - (metrics[:padding] * 2)
    inner - author_band(metrics[:author_font]) - AUTHOR_GAP - (metrics[:padding] * 2)
  end

  def small_title_height(metrics)
    inner = metrics[:height] - (metrics[:small_padding] * 2)
    inner - (metrics[:padding] * 2) - author_band(metrics[:small_text_font]) - SMALL_SEPARATOR
  end

  def author_band(font)
    (font * AUTHOR_LINE_HEIGHT * AUTHOR_MAX_LINES) + AUTHOR_BAND_FUDGE
  end

  def text_width(metrics, small:)
    inset = metrics[:padding] * (small ? 4 : 2)
    metrics[:width] - inset
  end

  def chars_per_line(width, font, em_ratio)
    [(width / (font * em_ratio)).floor, 1].max
  end

  def truncate(text, max)
    budget = max - OMISSION.length
    return OMISSION if budget <= 0

    slice = text[0, budget]
    cut = slice.rindex(' ')
    slice = slice[0, cut] if cut && cut > (budget / 2)
    "#{slice.rstrip}#{OMISSION}"
  end
  private_class_method :title_lines, :standard_title_height, :small_title_height,
                       :author_band, :text_width, :chars_per_line, :truncate
end
